import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/timeorder/time_order.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/error/error.dart';
import 'package:o2o/ui/screen/packing/packing.dart';
import 'package:o2o/ui/screen/picking/picking.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/common/loader/color_loader.dart';
import 'package:o2o/ui/widget/common/sliver_app_bar_delegate.dart';
import 'package:o2o/ui/widget/common/topbar.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/widget/order_list_item.dart';
import 'package:o2o/ui/widget/snackbar/snackbar_util.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/lib/remote/http_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Created by mdhasnain on 29 Jan, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Show the order list under a time order item
/// 2. Show the picking and picking completed order list separately
/// 3. Show which order is under processing now

class OrderList extends StatefulWidget {
  OrderList({Key key, this.timeOrder}) : super(key: key);
  final TimeOrder timeOrder;

  @override
  _OrderListState createState() => _OrderListState(timeOrder);
}

class _OrderListState extends BaseState<OrderList> {

  _OrderListState(this._timeOrder);
  final TimeOrder _timeOrder;

  final _refreshController = RefreshController(initialRefresh: true);
  
  /// Two different list to separate the picking and picking completed orders
  final _completedOrderItems = List();
  final _orderItems = List();

  String _myIMEI = '';
  String _myDeviceName = '';

  /// Build the title for each list
  _sectionTitleBuilder(title) {
    return Container(
      margin: EdgeInsets.only(left: 16, top: 16),
      child: CommonWidget.sectionTitleBuilder(title, fontSize: 16),
    );
  }

  /// widget to show the currently under work view on an order
  _anotherDeviceIsPickingNow() {
    return Container(
      height: 108,
      decoration: BoxDecoration(
        color: Color(0xEF889CB0),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      alignment: Alignment.center,
      child: Text(
        'デバイス01　対応中',
        style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  /// Empty screen view for the picking completed order list
  _emptyCompletedList() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white70,
        border: Border.all(width: 1.0, color: Colors.grey.shade300),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      alignment: Alignment.center,
      child: Text(
        '現在対応が必要な注文はありません。',
        style: TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }

  /// Picking completed orders list view
  _pickingCompletedList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final item = _completedOrderItems[index];
          if(item is OrderItem && item.isUnderWork(_myDeviceName)) {
            return Stack(
              children: <Widget>[
                OrderListItem(
                  context: context,
                  orderItem: item,
                ),
                InkWell(
                  child: _anotherDeviceIsPickingNow(),
                  onTap: () => _confirmPacking(item),
                ),
              ],
            );
          }
          return OrderListItem(
            context: context,
            orderItem: item,
            onPressed: () => _confirmPacking(item),
          );
        },
        childCount: _completedOrderItems.length,
      ),
    );
  }

  /// Picking orders list view
  _pickingList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          final item = _orderItems[index];
          if(item is OrderItem && item.isUnderWork(_myDeviceName)) {
            return Stack(
              children: <Widget>[
                OrderListItem(
                  context: context,
                  orderItem: item,
                ),
                InkWell(
                  child: _anotherDeviceIsPickingNow(),
                  onTap: () => _confirmPicking(item),
                ),
              ],
            );
          }
          return OrderListItem(
            context: context,
            orderItem: item,
            onPressed: () => _confirmPicking(item),
          );
        },
        childCount: _orderItems.length,
      ),
    );
  }

  /// This the body widget of the 'OrderListScreen'
  /// There are several checks inside it based on 'loadingState'
  /// 1. If the there is error on api response the error screen is showed
  /// 2. If the api returns no data then no data screen is showed
  /// 3. Finally if we get data then a List is showed with a PullToRefresh widget
  _bodyBuilder() {
    final deliveryTime = _timeOrder.scheduledDeliveryDateTime.substring(
        _timeOrder.scheduledDeliveryDateTime.lastIndexOf(" ")
    );
    final deliveryHour = deliveryTime.substring(0, deliveryTime.indexOf(':'));
    final deliveryMin = deliveryTime.substring(deliveryTime.indexOf(':') + 1);

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
            slivers: <Widget>[
              SliverPersistentHeader(
                  delegate: SliverAppBarDelegate(
                    minHeight: 36,
                    maxHeight: 36,
                    child: CommonWidget.sectionTimeBuilder(deliveryHour, deliveryMin),
                  ),
                  pinned: true
              ),
              SliverToBoxAdapter(
                child: _sectionTitleBuilder(locale.txtOrderRequiredDeliveryPreparation),
              ),
              _completedOrderItems.isEmpty? SliverToBoxAdapter(
                child: _emptyCompletedList(),
              ) : _pickingCompletedList(),
              SliverToBoxAdapter(
                child: _sectionTitleBuilder(locale.txtRequiredPickingOrder),
              ),
              _pickingList(),
            ],
          ),
          controller: _refreshController,
          onRefresh: () => _fetchData(),
        );
  }

  /// Main building block of the screen
  /// 1. 'TopBar' is a custom app bar for showing custom navigation icon,
  /// custom title and custom menu
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: TopBar(
        title: locale.txtOrderList,
        navigationIcon: AppImages.loadSizedImage(
          AppImages.icBackToTimeOrderListUrl, width: 68.48, height: 32.0
        ), ///The back button icon is 210:98 = 2.14:1. So width:height = 68.48:32
      ),
      backgroundColor: AppColors.background,
      body: _bodyBuilder(),
    );
  }

  /// This is an async function to fetch order list from the server
  /// It reads the imei from the SharedPreferences and try to send it to
  /// server along with the 'deliveryDateTime' of the timeOrder using the api
  /// 'GET_ORDER_LIST'.
  /// Then it checks the response for valid/invalid response code and update
  /// the state with new data
  _fetchData() async {
    //if (loadingState == LoadingState.LOADING) return;

    //setState(() => loadingState = LoadingState.LOADING);

    _myDeviceName = await PrefUtil.read(PrefUtil.DEVICE_NAME);

    _myIMEI = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = _myIMEI;
    params[Params.DELIVERY_DATE_TIME] = _timeOrder.scheduledDeliveryDateTime;

    final response = await HttpUtil.get(HttpUtil.GET_ORDER_LIST, params: params);
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

    LoadingState newState = LoadingState.NO_DATA;
    if((responseMap[Params.DATA] is List)) {
      final List data = responseMap[Params.DATA];
      List<OrderItem> items = data.map((data) => OrderItem.fromJson(data))
          .toList();
//    List<OrderItem> items = OrderItem.dummyOrderItems();

      if (_orderItems.isNotEmpty || items.isNotEmpty) {
        _completedOrderItems.clear();
        _orderItems.clear();
        items.forEach((item) {
          if(item.pickingStatus == PickingStatus.DONE) _completedOrderItems.add(item);
          else _orderItems.add(item);
        });

        newState = LoadingState.OK;
      }
    }

    setState(() => loadingState = newState);
  }

  /// Confirmation dialog before starting the picking of an order
  /// On confirmation check and update the picking status on server and then
  /// start picking
  _confirmPicking(OrderItem orderItem) {
    bool isUnderWork = orderItem.isUnderWork(_myDeviceName);
    ConfirmationDialog(
      context,
      locale.txtStartPicking,
      isUnderWork? locale.warningOtherDeviceIsPicking : locale.msgStartPicking,
      locale.txtStart, () => _startPickingForResult(orderItem, isUnderWork),
      msgTxtColor: isUnderWork ? Colors.redAccent : Colors.black,
    ).show();
  }

  /// After confirming picking task of an order item, this function launches
  /// the 'PickingScreen' for picking task and waits for the result of
  /// completing picking and packing.
  /// If we get the result from the packing we reload the data of this page
  _startPickingForResult(OrderItem orderItem, bool isUnderWork) async {

    final params = HashMap();
    params[Params.SERIAL] = _myIMEI;
    params[Params.ORDER_ID] = orderItem.orderId;
    params[Params.STATUS] = PickingStatus.WORKING;

    CommonWidget.showLoader(context, cancelable: false);
    final response = await HttpUtil.post(HttpUtil.UPDATE_PICKING_STATUS, params);
    if (response.statusCode != HttpCode.OK) {
      Navigator.pop(context);
      SnackbarUtil.show(context, locale.errorServerIsNotAvailable,);
      return;
    }

    final responseMap = json.decode(response.body);
    Navigator.pop(context);
    final code = responseMap[Params.CODE];
    if(code != HttpCode.OK) {
      _showToast('ピッキングステータスは更新する事ができません。');
      return;
    }

    final results = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PickingScreen(
          orderItem: orderItem,
          isUnderWork: isUnderWork,
        )
    ));

    _fetchData();

    if (results != null
        && results.containsKey(Params.ORDER_ID)
        && results.containsKey(Params.STATUS)
    ) {
      final orderId = 22223345677888;
      final status = results[Params.STATUS];

      String msg = '${locale.txtOrderNumber} : $orderId...の';
      if(status == TransitStatus.PICKING_DONE) {
        msg += 'ピッキング';
      } else if(status == TransitStatus.PACKING_DONE) {
        msg += '発送準備';
      } else if(status == TransitStatus.STOCK_OUT) {
        msg += '発送準備';
      }
      msg += 'を完了しました。';
      SnackbarUtil.show(context, msg,);
    }
  }

  /// This function uses 'UPDATE_PICKING_STATUS' api to update the picking
  /// status as done and show the confirmation dialog to start packing
  _confirmPacking(OrderItem orderItem) async {
    bool isUnderWork = orderItem.isUnderWork(_myDeviceName);
    ConfirmationDialog(
        context,
        locale.txtStartShippingPreparation,
        isUnderWork? locale.warningOtherDeviceIsPicking : locale.msgStartPicking,
        locale.txtStart, () => _startPackingForResult(orderItem, isUnderWork)
    ).show();
  }

  /// Start packing when all items are picked.
  /// First change the packing status of the order as working
  /// Then Go to the packing screen and wait for the result
  _startPackingForResult(OrderItem orderItem, bool isUnderWork) async {

    CommonWidget.showLoader(context, cancelable: false);
    final params = HashMap();
    params[Params.SERIAL] = _myIMEI;
    params[Params.ORDER_ID] = orderItem.orderId;
    params[Params.STATUS] = PackingStatus.WORKING;
    var response = await HttpUtil.post(HttpUtil.UPDATE_PACKING_STATUS, params);
    Navigator.of(context).pop();
    if (response.statusCode != HttpCode.OK) {
      _showToast(locale.errorServerIsNotAvailable,);
      return;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap[Params.CODE];
    if(code != HttpCode.OK) {
      _showToast('パッキングStatusは更新する事ができません。');
      return;
    }
    
    final results = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PackingScreen(
              orderItem: orderItem,
              isUnderWork: isUnderWork,
            )
    ));

    if (results != null && results.containsKey(Params.ORDER_ID)) {
      _fetchData();
      String msg = locale.txtOrderNumber + ' : '
          + '${results[Params.ORDER_ID]} の発送準備を完了しました。';
      SnackbarUtil.show(context, msg, durationInSec: 3);
    }
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

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
