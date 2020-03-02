import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/timeorder/time_order.dart';
import 'package:o2o/data/timeorder/time_order_heading.dart';
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
import 'package:o2o/util/HttpUtil.dart';

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

//    if(_selectedChoice == _choices[0]) _searchOrder('');
    if(_selectedChoice == _choices[0]) _scanBarcode();
    if(_selectedChoice == _choices[1]) _scanQrCode();
  }

  void _initChoices() {
    _choices.clear();
    _choices.add(Choice(title: locale.txtReadBarcode, icon: AppIcons.loadIcon(AppIcons.icBarCode, color: AppColors.colorBlue)));
    _choices.add(Choice(title: locale.txtReadQRCode, icon: AppIcons.loadIcon(AppIcons.icQrCode, color: AppColors.colorBlue)));

    _selectedChoice = _choices[0];
  }

  List _timeOrders = new List();
  List _shippingCompletedList = new List();
  List _missingList = new List();

  _fetchData() async {
    if (loadingState == LoadingState.LOADING) return;

    setState(() => loadingState = LoadingState.LOADING);

    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final requestBody = HashMap();
    requestBody['imei'] = imei;

    final response = await HttpUtil.postReq(AppConst.GET_TIME_ORDER_HISTORY, requestBody);
    print('code: ${response.statusCode}');
//    if (response.statusCode != 200) {
//      setState(() => loadingState = LoadingState.ERROR);
//      return;
//    }

    List tempList = new List();
    tempList.add(TimeOrder(
        scheduledDeliveryDateTime: "111 12:30",
        orderCount: 1,
        incompleteOrderCount: 2,
        totalProductCount: 3
    ));

    _timeOrders.add(TimeOrderHeading(10, 12, '金'));
    _shippingCompletedList.add(TimeOrderHeading(10, 12, '金'));
    _missingList.add(TimeOrderHeading(10, 12, '金'));

    LoadingState newState = LoadingState.NO_DATA;
    if (_timeOrders.isNotEmpty || tempList.isNotEmpty) {
      newState = LoadingState.OK;

      _timeOrders.addAll(tempList);
      _shippingCompletedList.addAll(tempList);
      _missingList.addAll(tempList);
    }

    setState(() => loadingState = newState);
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

  ScrollController _scrollController;
  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _fetchData();
    }
//    if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
//      fetchData();
//    }
  }

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
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: _choices[0].icon,
              onPressed: () {
                _select(_choices[0]);
              },
            ),
            IconButton(
              icon: _choices[1].icon,
              onPressed: () {
                _select(_choices[1]);
              },
            ),
          ],
        )
      ],
    );
  }

  _controllerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        GradientButton(
          text: locale.txtShippingPreparationComplete,
          txtColor: _currentPage == 0? Colors.white : Colors.lightBlue,
          fontWeight: FontWeight.w800,
          onPressed: () => _scrollToPage(0),
          gradient: _currentPage == 0? AppColors.btnGradient : AppColors.lightGradient,
        ),
        GradientButton(
          text: locale.txtShippingDone,
          txtColor: _currentPage == 1? Colors.white : Colors.lightBlue,
          fontWeight: FontWeight.w800,
          onPressed: () => _scrollToPage(1),
          gradient: _currentPage == 1? AppColors.btnGradient : AppColors.lightGradient,
        ),
        GradientButton(
          text: locale.txtMissing,
          txtColor: _currentPage == 2? Colors.white : Colors.lightBlue,
          fontWeight: FontWeight.w800,
          onPressed: () => _scrollToPage(2),
          gradient: _currentPage == 2? AppColors.btnGradient : AppColors.lightGradient,
          padding: 32.0,
        ),
      ],
    );
  }

  _buildList(timeOrders, historyType) {
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

    ) : ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: timeOrders.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == timeOrders.length) {
          return CommonWidget.buildProgressIndicator(loadingState);
        } else {
          final currentItem = timeOrders[index];
          if (currentItem is TimeOrderHeading) {
            return CommonWidget.sectionDateBuilder(
                currentItem.month, currentItem.day, currentItem.dayStr);
          }
          return TimeOrderHistoryItem(
              context: context,
              timeOrder: timeOrders[index],
              historyType: historyType,
          );
        }
      },
      controller: _scrollController,
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
  _scrollToPage(int page) {
    setState(() => _currentPage = page);
    _pageController.removeListener(_pageScrollListener);
    _pageController.animateToPage(
        page, duration: Duration(milliseconds: 500), curve: Curves.decelerate
    ).then((value) => _pageController.addListener(_pageScrollListener));
  }

  _bodyBuilder() {
    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, position) {
        List orderList = _timeOrders;
        HistoryType historyType = HistoryType.PLANNING;
        if(position == 1) {
          orderList = _shippingCompletedList;
          historyType = HistoryType.COMPLETE;
        } else if(position == 2) {
          orderList = _missingList;
          historyType = HistoryType.MISSING;
        }

        return _buildList(orderList, historyType);
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
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _initChoices();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 230, 242, 255),
      appBar: AppBar(
        title: _sectionTitleBuilder(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Color.fromARGB(255, 230, 242, 255),
            child: _controllerButtons(),
          ),
        ),
      ),
      body: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}