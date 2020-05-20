import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/timeorder/time_order_heading.dart';
import 'package:o2o/data/timeorder/time_order_list_item.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/error/error.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/loader/color_loader.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/time_order_item.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/helper/common.dart';
import 'package:o2o/util/lib/remote/http_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Created by mdhasnain on 28 Jan, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Show the list of orders by time
/// 2.
/// 3.

class TimeOrderListScreen extends StatefulWidget {
  @override
  _TimeOrderListScreenState createState() => _TimeOrderListScreenState();
}

class _TimeOrderListScreenState extends BaseState<TimeOrderListScreen> {
  /// List of timeOrders and timeOrderHeaders data
//  final _timeOrders = List();
  final Map<TimeOrderHeading, List> _timeOrders = LinkedHashMap();

  final _refreshController = RefreshController(initialRefresh: true);

  String _deviceName = '';
  String _storeName = '';

  /// Scroll position detector for the list view.
  /// It is used for load more feature in list view
  /// Right now in time order list it is not being used
  /// N.b. Not in use now
  ScrollController _scrollController;

  /// Listener for the scrollController.
  /// Each time the list makes a scroll we listen that here
  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
//      _fetchData();
    }
//    if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
//      fetchData();
//    }
  }

  /// App bar custom title builder
  _sectionTitleBuilder() {
    return Container(
      height: 60,
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AppIcons.loadIcon(AppIcons.icList, color: AppColors.colorBlue),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              locale.homeNavigation1Title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

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
          return TimeOrderItem(context: context, timeOrder: currentItem);
        },
          childCount: slivers.length,
        ),
      ),
    );
  }

  /// The list view of the time order items.
  /// This list contains two types of widgets.
  /// If the item is a 'TimeOrderHeading', it is set as a pinned header
  /// If not, the list of 'TimeOrderItem' is set under the header
  _buildTimeOrderList() {
    final List<Widget> slivers = List();
    _timeOrders.forEach((key, value) {
      slivers.add(_buildPinnedHeaderList(key, value));
    });
    slivers.add(SliverFillRemaining(
      hasScrollBody: false,
      fillOverscroll: true,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          child: Text(
            '短時間配送支援アプリ　　B版\nココカラファイン$_storeName　$_deviceName',
            style: TextStyle(color: Colors.black, fontSize: 14.0),
            textAlign: TextAlign.center,
          ),
          padding: EdgeInsets.all(16.0),
        ),
      ),
    ));
    return slivers;
//    return SliverList(
//      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
//        final currentItem = _timeOrders[index];
//        if (currentItem is TimeOrderHeading) {
//          return CommonWidget.sectionDateBuilder(
//              currentItem.month, currentItem.day, currentItem.dayStr);
//        }
//        return TimeOrderItem(context: context, timeOrder: currentItem);
//        },
//        childCount: _timeOrders.length,
//      ),
//    );
  }

  /// This the body widget of the 'TimeOrderListScreen'
  /// There are several checks inside it based on 'loadingState'
  /// 1. If the there is error on api response the error screen is showed
  /// 2. If the api returns no data then no data screen is showed
  /// 3. Finally if we get data then a List is showed with a PullToRefresh widget
  _bodyBuilder() {
    return loadingState == LoadingState.ERROR
        ? ErrorScreen(
        errorMessage: locale.errorMsgCannotGetData,
        btnText: locale.txtReload,
        onClickBtn: () => _fetchData(),
        showHelpTxt: true
    ) : loadingState == LoadingState.NO_DATA
        ? ErrorScreen(
      errorMessage: locale.errorMsgNoData,
      btnText: locale.refreshOrderList,
      onClickBtn: () => _fetchData(),
    ) : loadingState == LoadingState.LOADING
        ? ColorLoader() : SmartRefresher(
      enablePullDown: true,
      header: ClassicHeader(
        idleText: locale.txtPullToRefresh,
        refreshingText: locale.txtRefreshing,
        completeText: locale.txtRefreshCompleted,
        releaseText: locale.txtReleaseToRefresh,
      ),
      child: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: _buildTimeOrderList(),
      ),
      controller: _refreshController,
      onRefresh: () => _fetchData(),
    );
  }

  /// 1. Initialize the list view scroll controller
  /// 2. Fetching the time order list for the first time
  @override
  void initState() {
    super.initState();
    _readDeviceInfo();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    //_fetchData();
  }

  /// Main building block of the screen
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _sectionTitleBuilder(),
      ),
      body: _bodyBuilder(),
    );
  }

  /// This is an async function to fetch time order list from the server
  /// It reads the imei from the SharedPreferences and try to send it to
  /// server using the api 'GET_TIME_ORDER'.
  /// Then it checks the response for valid/invalid response code and update
  /// the state with new data
  _fetchData() async {
    //if (loadingState == LoadingState.LOADING) return;

    //setState(() => loadingState = LoadingState.LOADING);

    String imei = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = imei;

    final response = await HttpUtil.get(HttpUtil.GET_TIME_ORDER, params: params);
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
      _timeOrders.clear();
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final dateTime = Common.convertToDateTime(item.date);
        final header = TimeOrderHeading(
          dateTime.day, dateTime.month, AppConst.WEEKDAYS[dateTime.weekday-1],
        );
        _timeOrders[header] = item.timeOrderSummaryList;
//        _timeOrders.add(TimeOrderHeading(
//          dateTime.day, dateTime.month, AppConst.WEEKDAYS[dateTime.weekday-1],
//        ));
//        _timeOrders.addAll(item.timeOrderSummaryList);
      }

      newState = LoadingState.OK;
    }

    setState(() => loadingState = newState);
  }

  _readDeviceInfo() async {
    String deviceName = await PrefUtil.read(PrefUtil.DEVICE_NAME);
    String storeName = await PrefUtil.read(PrefUtil.STORE_NAME);

    setState(() {
      _deviceName = deviceName;
      _storeName = storeName;
    });
  }

  _showToast(
      String msg, {
        error = true,
      }) {
    final icon = AppIcons.loadIcon(
        error? AppIcons.icError : AppIcons.icLike, color: Colors.white, size: 16.0
    );
    ToastUtil.show(context, msg, icon: icon, error: error);
  }

  /// This is where we dispose our list scroll controller
  @override
  void dispose() {
    _scrollController?.dispose();
    _refreshController.dispose();
    super.dispose();
  }
}
