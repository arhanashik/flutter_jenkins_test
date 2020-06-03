import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/timeorder/time_order_heading.dart';
import 'package:o2o/data/timeorder/time_order_list_item.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/error/error.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/time_order_history_item.dart';
import 'package:o2o/util/helper/common.dart';
import 'package:o2o/util/lib/remote/http_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'history_type.dart';

/// Created by mdhasnain on 30 Apr, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3. 

class HistoryListScreen extends StatefulWidget {
  
  HistoryListScreen({Key key, this.historyType}): super(key: key);
  final HistoryType historyType;
  @override
  _HistoryListScreenState createState() => _HistoryListScreenState();
}

class _HistoryListScreenState extends BaseState<HistoryListScreen> {

  final Map<TimeOrderHeading, List> _dataMap = LinkedHashMap();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  /// Builds the 'SliverStickyHeader' which consists of a 'TimeOrderHeading'
  /// and the 'TimeOrderItem' list under that header
  _buildPinnedHeaderList(TimeOrderHeading heading, List slivers) {
    return SliverStickyHeader(
      header: CommonWidget.sectionDateBuilder(
          heading.month, heading.day, heading.dayStr
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final currentItem = slivers[index];
          return TimeOrderHistoryItem(
            context: context,
            timeOrder: currentItem,
            historyType: widget.historyType,
          );
        },
          childCount: slivers.length,
        ),
      ),
    );
  }

  _buildHistoryList() {
    final List<Widget> slivers = List();
    _dataMap.forEach((key, value) {
      slivers.add(_buildPinnedHeaderList(key, value));
    });

    return slivers;
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return loadingState == LoadingState.ERROR ? ErrorScreen(
        errorMessage: locale.errorMsgCannotGetData,
        btnText: locale.txtReload,
        onClickBtn: () => _fetchData(),
        showHelpTxt: true
    ) : loadingState == LoadingState.NO_DATA ? ErrorScreen(
      errorMessage: locale.errorMsgNoHistoryData,
      btnText: '対応履歴を更新する',
      onClickBtn: () => _fetchData(),
    ) : SmartRefresher(
      enablePullDown: true,
      header: ClassicHeader(
        idleText: locale.txtPullToRefresh,
        refreshingText: locale.txtRefreshing,
        completeText: locale.txtRefreshCompleted,
        releaseText: locale.txtReleaseToRefresh,
      ),
      child: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: _buildHistoryList(),
      ),
      controller: _refreshController,
      onRefresh: () => _fetchData(),
    );
  }

  _fetchData() async {
    if (loadingState == LoadingState.LOADING) return;

    setState(() => loadingState = LoadingState.LOADING);

    String imei = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = imei;

    String url = HttpUtil.GET_HISTORY_LIST_BEFORE_SHIPPING;
    if(widget.historyType == HistoryType.DELIVERED)
      url = HttpUtil.GET_HISTORY_LIST_DELIVERED;
    else if(widget.historyType == HistoryType.STOCK_OUT)
      url = HttpUtil.GET_HISTORY_LIST_STOCK_OUT;
    final response = await HttpUtil.get(url, params: params);
    _refreshController.refreshCompleted();
    if (response.statusCode != HttpCode.OK) {
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }
    final responseMap = json.decode(response.body);
    final code = responseMap[Params.CODE];
    if(code != HttpCode.OK) {
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }
    final List data = responseMap[Params.DATA];
    List<TimeOrderListItem> items = data.map(
            (data) => TimeOrderListItem.fromJson(data)
    ).toList();
//    List<TimeOrderListItem> items = TimeOrderListItem.dummyTimeOrderList();
    LoadingState newState = LoadingState.NO_DATA;
    if (items.isNotEmpty) {
      _dataMap.clear();
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final dateTime = Converter.toDateTime(item.date);
        final header = TimeOrderHeading(
          dateTime.day, dateTime.month, AppConst.WEEKDAYS[dateTime.weekday-1],
        );
        _dataMap[header] = item.timeOrderSummaryList;
      }

      newState = LoadingState.OK;
    }

    setState(() => loadingState = newState);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}