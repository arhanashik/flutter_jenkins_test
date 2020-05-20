import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/timeorder/time_order.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/error/error.dart';
import 'package:o2o/ui/screen/orderlisthistory/oder_history_details.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/order_history_list_item.dart';
import 'package:o2o/util/helper/common.dart';
import 'package:o2o/util/lib/remote/http_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../home/history/history_type.dart';

/// Created by mdhasnain on 06 Feb, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1.
/// 2.
/// 3.

class OrderListHistoryScreen extends StatefulWidget {

  OrderListHistoryScreen(this.timeOrder, this.historyType);
  final TimeOrder timeOrder;
  final HistoryType historyType;

  @override
  _OrderListHistoryScreenState createState() => _OrderListHistoryScreenState();
}

class _OrderListHistoryScreenState extends BaseState<OrderListHistoryScreen> {

  List _orderHistoryList = new List();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  _buildTitle() {
    final dateTime = Common.convertToDateTime(widget.timeOrder.scheduledDeliveryDateTime);
    final dayStr = AppConst.WEEKDAYS[dateTime.weekday-1];

    final deliveryTime = widget.timeOrder.scheduledDeliveryDateTime.substring(
        widget.timeOrder.scheduledDeliveryDateTime.lastIndexOf(" ")
    );
    final deliveryHour = deliveryTime.substring(0, deliveryTime.indexOf(':'));
    final deliveryMin = deliveryTime.substring(deliveryTime.indexOf(':') + 1);

    return Container(
      height: 36,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.blueGradient)
      ),
      padding: EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        children: <Widget>[
          CommonWidget.boldTextBuilder(dateTime.month.toString(), 22),
          Padding(
            padding: EdgeInsets.only(right: 5, top: 8),
            child: CommonWidget.boldTextBuilder('月', 12),
          ),
          CommonWidget.boldTextBuilder(dateTime.day.toString(), 22),
          Padding(
            padding: EdgeInsets.only(right: 5, top: 8),
            child: CommonWidget.boldTextBuilder('日', 12),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: CommonWidget.boldTextBuilder('($dayStr)', 14),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: CommonWidget.boldTextBuilder('$deliveryHour:$deliveryMin', 22),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5, top: 5),
            child: CommonWidget.boldTextBuilder('発送分', 12),
          ),
        ],
      ),
    );
  }

  ScrollController _scrollController;

  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent
        && !_scrollController.position.outOfRange
        && _orderHistoryList.length > 5) {
      _fetchData();
    }
//    if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
//      fetchData();
//    }
  }

  _buildList() {
    int totalItems = _orderHistoryList.length;
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: totalItems + (totalItems>5? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (totalItems > 5 && index == totalItems) {
          return CommonWidget.buildProgressIndicator(loadingState);
        }
        final item = _orderHistoryList[index];
        return OrderHistoryListItem(
          context: context,
          orderItem: item,
          historyType: widget.historyType,
          onPressed:  () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => OrderHistoryDetailsScreen(
                    item, widget.historyType
                )
            ));
          },
        );
      },
      controller: _scrollController,
    );
  }

  _bodyBuilder() {
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
      child: _buildList(),
      controller: _refreshController,
      onRefresh: () => _fetchData(),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    String titleLeading = locale.txtBeforeShipping;
    if(widget.historyType == HistoryType.DELIVERED) titleLeading = '発送済み';
    if(widget.historyType == HistoryType.STOCK_OUT) titleLeading = '欠品';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        leading: Container(
          padding: EdgeInsets.only(left: 13, top: 12, bottom: 12, right: 4,),
          child: InkWell(
            child: AppImages.loadSizedImage(AppImages.icBackToPreviousUrl,),
            onTap: () => Navigator.of(context).pop(),
          )
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              color: AppColors.background,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                titleLeading,
                style: TextStyle(fontSize: 14, color: AppColors.colorBlueDark),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 10),),
            Text(locale.homeNavigation2Title),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(36.0),
          child: _buildTitle(),
        ),
      ),
      body: _bodyBuilder(),
    );
  }

  _fetchData() async {
    if (loadingState == LoadingState.LOADING) return;

    setState(() => loadingState = LoadingState.LOADING);

    String imei = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = imei;
    params[Params.DELIVERY_DATE_TIME] = widget.timeOrder.scheduledDeliveryDateTime;

    String url = HttpUtil.GET_HISTORY_LIST_READY_TO_SHIP;
    if(widget.historyType == HistoryType.DELIVERED)
      url = HttpUtil.GET_HISTORY_LIST_SPECIFIED_TIME;
    else if(widget.historyType == HistoryType.STOCK_OUT)
      url = HttpUtil.GET_HISTORY_LIST_SPECIFIED_TIME_STOCK_OUT;
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
    List<OrderItem> items = data.map(
            (data) => OrderItem.fromJson(data)
    ).toList();
//    List<TimeOrderListItem> items = TimeOrderListItem.dummyTimeOrderList();
    LoadingState newState = LoadingState.NO_DATA;
    if (items!= null && items.isNotEmpty) {
      _orderHistoryList.clear();
      _orderHistoryList.addAll(items);

      newState = LoadingState.OK;
    }

    setState(() => loadingState = newState);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}