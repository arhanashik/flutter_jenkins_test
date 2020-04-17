import 'dart:collection';

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
import 'package:o2o/ui/screen/home/history/order_list_history.dart';
import 'package:o2o/ui/screen/home/history/search_history.dart';
import 'package:o2o/ui/screen/scanner/barcode_scanner.dart';
import 'package:o2o/ui/screen/scanner/qrcode_scanner.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/widget/time_order_history_item.dart';
import 'package:o2o/util/helper/common.dart';
import 'package:o2o/util/lib/remote/http_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Created by mdhasnain on 04 Jan, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Shows the list of orders
/// 2.
/// 3.

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final ImageIcon icon;
}

class _HistoryScreenState extends BaseState<HistoryScreen> {

  int _currentPage = 0;
  PageController _pageController;
  _pageScrollListener() {
    setState(() => _currentPage = _pageController.page.ceil());
  }

  List<Choice> _choices = List();
  Choice _selectedChoice;
  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
    });

    if(_selectedChoice == _choices[0]) _scanBarcode();
    if(_selectedChoice == _choices[1]) _scanQrCode();
  }

  void _initChoices() {
    _choices.clear();
    _choices.add(
        Choice(
            title: locale.txtReadBarcode,
            icon: AppIcons.loadIcon(AppIcons.icBarCode, color: AppColors.colorBlue, size: 18.0)
        )
    );
    _choices.add(
        Choice(
            title: locale.txtReadQRCode,
            icon: AppIcons.loadIcon(AppIcons.icQrCode, color: AppColors.colorBlue, size: 18.0)
        )
    );

    _selectedChoice = _choices[0];
  }

  final Map<TimeOrderHeading, List> _timeOrders = HashMap();
  final Map<TimeOrderHeading, List> _shippingCompletedList = HashMap();
  final Map<TimeOrderHeading, List> _missingList = HashMap();

  final _refreshController = RefreshController(initialRefresh: false);

   _sectionTitleBuilder() {
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: <Widget>[
        Container(
          height: 60,
          color: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                locale.homeNavigation2Title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              child: Column(
                children: <Widget>[
                  _choices[0].icon,
                  Padding(padding: EdgeInsets.only(top: 3),),
                  Text(
                    'バーコード読取',
                    style: TextStyle(color: AppColors.colorBlueDark, fontSize: 10.0),
                  )
                ],
              ),
              onTap: () => _select(_choices[0]),
            ),
            Padding(padding: EdgeInsets.only(left: 8),),
            InkWell(
              child: Column(
                children: <Widget>[
                  _choices[1].icon,
                  Padding(padding: EdgeInsets.only(top: 3),),
                  Text(
                    'QR読取',
                    style: TextStyle(color: AppColors.colorBlueDark, fontSize: 10.0),
                  )
                ],
              ),
              onTap: () => _select(_choices[1]),
            ),
          ],
        )
      ],
    );
  }

  _buildControlBtn(
      int btnIndex,
      String txt, {
        EdgeInsets padding: const EdgeInsets.symmetric(horizontal: 32.0,),
  }) {
    return Container(
      height: 36.0,
      decoration: _buildControlBtnBorder(btnIndex),
      child: GradientButton(
        text: txt,
        txtColor: _currentPage == btnIndex? Colors.white : Colors.black,
        fontWeight: FontWeight.w800,
        onPressed: () => _scrollToPage(btnIndex),
        gradient: _currentPage == btnIndex? AppColors.btnGradient : AppColors.lightGradient,
        borderRadius: 5.0,
        padding: padding,
      ),
    );
  }

  _buildControlBtnBorder(int btnIndex) {
    return _currentPage == btnIndex? null : BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    );
  }

  _controllerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildControlBtn(0, locale.txtBeforeShipping),
        _buildControlBtn(1, locale.txtShippingDone),
        _buildControlBtn(2, locale.txtMissing),
      ],
    );
  }

  /// Builds the 'SliverStickyHeader' which consists of a 'TimeOrderHeading'
  /// and the 'TimeOrderItem' list under that header
  _buildPinnedHeaderList(TimeOrderHeading heading, List slivers, historyType) {
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
            historyType: historyType,
          );
        },
          childCount: slivers.length,
        ),
      ),
    );
  }

  _buildHistoryList(Map<TimeOrderHeading, List> timeOrders, historyType) {
    final List<Widget> slivers = List();
    timeOrders.forEach((key, value) {
      slivers.add(_buildPinnedHeaderList(key, value, historyType));
    });

    return slivers;
  }

  _buildPage(Map<TimeOrderHeading, List> timeOrders, historyType) {
    return loadingState == LoadingState.ERROR ? ErrorScreen(
        errorMessage: locale.errorMsgCannotGetData,
        btnText: locale.txtReload,
        onClickBtn: () => _fetchData(),
        showHelpTxt: true
    ) : loadingState == LoadingState.NO_DATA
        ? ErrorScreen(
      errorMessage: locale.errorMsgNoData,
      btnText: locale.refreshOrderList,
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
        slivers: _buildHistoryList(timeOrders, historyType),
      ),
      controller: _refreshController,
      onRefresh: () => _fetchData(),
    );
  }

  /*
  * This function is used to manually scroll the page view.
  * In this function we set the _currentPage value manually.
  * Reason is animateToPage scrolls via all pages on the path.
  * So there is a glitch like each button on the path is clicked.
  * That's why we are removing the listener first so that the button state
  * doesn't get called automatically. After our manual scroll we add the
  * listener again.
  * */
  _scrollToPage(int page) async {
    setState(() => _currentPage = page);
    _pageController.removeListener(_pageScrollListener);
//    _pageController.jumpToPage(page);
    await _pageController.animateToPage(
        page, duration: Duration(milliseconds: 250), curve: Curves.decelerate
    );
    _pageController.addListener(_pageScrollListener);
  }

  _bodyBuilder() {
    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, position) {
        Map<TimeOrderHeading, List> orderList = _timeOrders;
        HistoryType historyType = HistoryType.PLANNING;
        if(position == 1) {
          orderList = _shippingCompletedList;
          historyType = HistoryType.COMPLETE;
        } else if(position == 2) {
          orderList = _missingList;
          historyType = HistoryType.MISSING;
        }

        return _buildPage(orderList, historyType);
      },
      itemCount: 3,
      physics: BouncingScrollPhysics(),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_pageScrollListener);
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _initChoices();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _sectionTitleBuilder(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Container(
            height: 56.0,
            color: AppColors.colorF1F1F1,
            child: _controllerButtons(),
          ),
        ),
      ),
      body: _bodyBuilder(),
    );
  }

  _fetchData() async {
    if (loadingState == LoadingState.LOADING) return;

    setState(() => loadingState = LoadingState.LOADING);

    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final params = HashMap();
    params['imei'] = imei;

    _refreshController.refreshCompleted();
    final response = await HttpUtil.get(HttpUtil.GET_TIME_ORDER_HISTORY, params: params);
//    if (response.statusCode != 200) {
//      setState(() => loadingState = LoadingState.ERROR);
//      return;
//    }
    List<TimeOrderListItem> items = TimeOrderListItem.dummyTimeOrderList();

    LoadingState newState = LoadingState.NO_DATA;
    if (items.isNotEmpty) {
      _timeOrders.clear();
      _shippingCompletedList.clear();
      _missingList.clear();
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final dateTime = Common.convertToDateTime(item.date);
        final header = TimeOrderHeading(
          dateTime.day, dateTime.month, AppConst.WEEKDAYS[dateTime.weekday-1],
        );
        _timeOrders[header] = item.timeOrderSummaryList;
        _shippingCompletedList[header] = item.timeOrderSummaryList;
        _missingList[header] = item.timeOrderSummaryList;
      }

      newState = LoadingState.OK;
    }

    setState(() => loadingState = newState);
  }

  _scanQrCode() async {
    final results = await Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => QrCodeScannerScreen(),
        fullscreenDialog: true,
      ),
    );

    if (results != null && results.containsKey('qrCode')) {
      String qrCode = results['qrCode'];
      if (qrCode.isNotEmpty) {
//        ToastUtil.showCustomToast(context, locale.txtScanned1QRCode);
        String msg = locale.txtScanned1QRCode + '\n\n'
            + locale.txtQrCodeNumber + '\n' + qrCode;
        ConfirmationDialog(
          context,
          locale.txtConfirm,
          msg,
          locale.txtOk,
              () => _searchOrder(qrCode),
        ).show();
      }
    }
  }

  _searchOrder(String qrCode) {
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => SearchHistory(
          searchQuery: qrCode,
        ),
      ),
    );
  }

  _scanBarcode() async {
    final results = await Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => BarcodeScannerScreen(),
        fullscreenDialog: true,
      ),
    );

    if (results != null && results.containsKey('barcode')) {
      String barcode = results['barcode'];
      if (barcode.isNotEmpty) {
//        ToastUtil.showCustomToast(context, locale.txtScanned1QRCode);
        String msg = locale.txtScanned1QRCode + '\n\n'
            + locale.txtQrCodeNumber + '\n' + barcode;
        ConfirmationDialog(
          context,
          locale.txtConfirm,
          msg,
          locale.txtOk,
              () => _searchOrder(barcode),
        ).show();
      }
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}