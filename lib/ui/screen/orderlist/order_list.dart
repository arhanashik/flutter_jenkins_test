import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/timeorder/time_order.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/error/error.dart';
import 'package:o2o/ui/screen/picking/picking.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/common/sliverAppBarDelegate.dart';
import 'package:o2o/ui/widget/common/topbar.dart';
import 'package:o2o/ui/widget/completed_order_list_item.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/widget/order_list_item.dart';
import 'package:o2o/ui/widget/snackbar/snackbar_util.dart';
import 'package:o2o/util/HttpUtil.dart';

/// Created by mdhasnain on 29 Jan, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1.
/// 2.
/// 3.

class OrderList extends StatefulWidget {
  final TimeOrder timeOrder;

  OrderList({Key key, this.timeOrder}) : super(key: key);

  @override
  _OrderListState createState() => _OrderListState(timeOrder);
}

class _OrderListState extends BaseState<OrderList> {

  _OrderListState(this._timeOrder);
  final TimeOrder _timeOrder;
  
  List _completedOrderItems = List();
  List _orderItems = List();

  Container _sectionTitleBuilder(title) {
    return Container(
      margin: EdgeInsets.only(left: 16, top: 16),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(width: 3.0, color: AppColors.colorBlue)),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Text(
          title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  _confirmStartPickingTask(OrderItem orderItem) {
    ConfirmationDialog(
      context,
      locale.txtStartPicking,
      locale.msgStartPicking,
      locale.txtStart, () => _startPickingTaskForResult(orderItem)
    ).show();
  }

  _anotherDeviceIsPickingNow() {
    return Container(
      height: 102,
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

  _emptyCompletedList() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white30,
        border: Border.all(width: 1.0, color: Colors.grey),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      alignment: Alignment.center,
      child: Text(
        locale.txtOrderRequiredDeliveryPreparation,
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }

  _shippingPreparationCompletedList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final item = _completedOrderItems[index];
          if(item is OrderItem
              && item.lockedName.isEmpty) {
            return Stack(
              children: <Widget>[
                OrderListItem(
                  context: context,
                  orderItem: item,
                  onPressed: () => _confirmStartPickingTask(item),
                ),
                _anotherDeviceIsPickingNow(),
              ],
            );
          }
          return OrderListItem(
            context: context,
            orderItem: item,
            onPressed: () => _confirmStartPickingTask(item),
          );
        },
        childCount: _completedOrderItems.length,
      ),
    );
  }

  _pickingList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          final item = _orderItems[index];
          if(item is OrderItem && item.pickingStatus == PickingStatus.WORKING) {
            return Stack(
              children: <Widget>[
                OrderListItem(
                  context: context,
                  orderItem: item,
                  onPressed: () => _confirmStartPickingTask(item),
                ),
                _anotherDeviceIsPickingNow(),
              ],
            );
          }
          return OrderListItem(
            context: context,
            orderItem: item,
            onPressed: () => _confirmStartPickingTask(item),
          );
        },
        childCount: _orderItems.length,
      ),
    );
  }

  _bodyBuilder() {
    final deliveryTime = _timeOrder.scheduledDeliveryDateTime.substring(
        _timeOrder.scheduledDeliveryDateTime.lastIndexOf(" ")
    );
    final deliveryHour = deliveryTime.substring(0, deliveryTime.indexOf(':'));
    final deliveryMin = deliveryTime.substring(deliveryTime.indexOf(':') + 1);

    return
        loadingState == LoadingState.ERROR
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

        ) : CustomScrollView(
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
            ) : _shippingPreparationCompletedList(),
            SliverToBoxAdapter(
              child: _sectionTitleBuilder(locale.txtRequiredPickingOrder),
            ),
            _pickingList(),
          ],
        );
  }

  @override
  void initState() {
    super.initState();

    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: TopBar(
        title: locale.txtOrderList,
        navigationIcon: AppIcons.loadIcon(
            AppIcons.icBackToTimeOrderList,
            size: 64.0,
            color: AppColors.colorBlue
        ),
      ),
//      appBar: AppBar(
//        leading: Container(
//          alignment: Alignment.center,
//          padding: EdgeInsets.only(left: 13.0),
//          child: CommonWidget.labeledButton(
//              AppIcons.loadIcon(AppIcons.icList, size: 17.0, color: AppColors.colorBlue),
//              "時間帯別一覧へ",
//                  () => Navigator.of(context).pop()
//          ),
//        ),
//        title: Text(locale.txtOrderList),
//        centerTitle: true,
//        bottom: PreferredSize(
//          preferredSize: Size.fromHeight(36.0),
//          child: CommonWidget.sectionTimeBuilder(deliveryHour, deliveryMin),
//        ),
//      ),
      backgroundColor: AppColors.background,
      body: _bodyBuilder(),
    );
  }

  _fetchData() async {
    if (loadingState == LoadingState.LOADING) return;

    setState(() => loadingState = LoadingState.LOADING);

    /*String imei = await PrefUtil.read(PrefUtil.IMEI);
    final requestBody = HashMap();
    requestBody['imei'] = imei;
    requestBody['deliveryDateTime'] = _timeOrder.scheduledDeliveryDateTime;

    final response = await HttpUtil.postReq(AppConst.GET_ORDER_LIST, requestBody);
    print('code: ${response.statusCode}');
    if (response.statusCode != 200) {
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }

    print('body: ${response.body}');
    List jsonData = json.decode(response.body);
    List<OrderItem> items = jsonData.map(
            (data) => OrderItem.fromJson(data)
    ).toList();*/
    List<OrderItem> items = OrderItem.dummyOrderItems();

    LoadingState newState = LoadingState.NO_DATA;
    if (_orderItems.isNotEmpty || items.isNotEmpty) {
      items.forEach((item) {
        if(item.pickingStatus == PickingStatus.DONE) _completedOrderItems.add(item);
        else _orderItems.add(item);
      });

      newState = LoadingState.OK;
    }

    setState(() => loadingState = newState);
  }

  _startPickingTaskForResult(OrderItem orderItem) async {
//    String imei = await PrefUtil.read(PrefUtil.IMEI);
//    final requestBody = HashMap();
//    requestBody['imei'] = imei;
//    requestBody['orderNo'] = orderItem.orderNo;
//    requestBody['status'] = PickingStatus.WORKING;
//
//    final response = await HttpUtil.postReq(AppConst.UPDATE_PICKING_STATUS, requestBody);
//    print('code: ${response.statusCode}');
//    if (response.statusCode != 200) {
//      SnackbarUtil.show(context, 'Failed to upate picking status');
//      return;
//    }

    orderItem.pickingStatus = PickingStatus.WORKING;
    final results = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PickingScreen(
          orderItem: orderItem,
        )
    ));

    if (results != null && results.containsKey('order_id')) {
      final item = _orderItems.firstWhere(
              (element) => element is OrderItem
                  && element.orderNo == results['order_id']
      );
      setState(() {
        _orderItems.remove(item);
        _completedOrderItems.add(item);
      });
      String msg = locale.txtOrderNumber + ' : '
          + '${results['order_id']} の発送準備を完了しました。';
      SnackbarUtil.show(context, msg, durationInSec: 3);
    }
  }
}
