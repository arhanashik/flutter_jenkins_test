import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/data/response/order_history_details_response.dart';
import 'package:o2o/ui/screen/addqrcode/full_screen_add_qr_code_dialog.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/deleteqrcode/full_screen_delete_qr_code_dialog.dart';
import 'package:o2o/ui/screen/error/error.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/widget/dialog/input_receipt_number_dialog.dart';
import 'package:o2o/ui/widget/packing_product_item.dart';
import 'package:o2o/ui/widget/snackbar/snackbar_util.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/helper/common.dart';
import 'package:o2o/util/lib/remote/http_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../home/history/history_type.dart';

/// Created by mdhasnain on 07 Feb, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1.
/// 2.
/// 3.

class OrderHistoryDetailsScreen extends StatefulWidget {

  OrderHistoryDetailsScreen(this.orderItem, this.historyType);
  final OrderItem orderItem;
  final HistoryType historyType;

  @override
  _OrderHistoryDetailsScreenState createState() => _OrderHistoryDetailsScreenState();
}

class _OrderHistoryDetailsScreenState extends BaseState<OrderHistoryDetailsScreen> {
  OrderHistoryDetails _orderHistoryDetails = OrderHistoryDetails();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  _buildTitle() {
    String dateStr = widget.orderItem.endingTime;
    if(widget.historyType == HistoryType.DELIVERED) dateStr = widget.orderItem.deliveredTime;
    else if(widget.historyType == HistoryType.STOCK_OUT) dateStr = widget.orderItem.stockoutReportDate;
    if(dateStr == null) dateStr = '1970-01-01 00:00';
    final dateTime = Converter.toDateTime(dateStr);
    final dayStr = AppConst.WEEKDAYS[dateTime.weekday-1];

    final deliveryTime = dateStr.substring(dateStr.lastIndexOf(' '));
    final deliveryHour = deliveryTime.substring(0, deliveryTime.indexOf(':'));
    final deliveryMin = deliveryTime.substring(deliveryTime.indexOf(':') + 1);

    String suffix = 'に';
    if(widget.historyType == HistoryType.PLANNING) suffix += '発送準備完了';
    else if(widget.historyType == HistoryType.DELIVERED) suffix += '発送済み';
    else if(widget.historyType == HistoryType.STOCK_OUT) suffix += '欠品報告済み';

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
            child: CommonWidget.boldTextBuilder(suffix, 12),
          ),
        ],
      ),
    );
  }

  _sectionTitleBuilder(title) {
    return Container(
      color: AppColors.background,
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  _textValuePair(text, value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: <Widget>[
          Text(
            '$text:',
            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  _deliveryInfoBuilder() {
    final endingTimeFull = _orderHistoryDetails.endingTime;
    final endingTime = endingTimeFull == null || endingTimeFull.isEmpty? ''
        : _orderHistoryDetails.endingTime.substring(
        _orderHistoryDetails.endingTime.indexOf(' ')
    );
    final deliveryTime = _orderHistoryDetails.appointedDeliveringTime.isEmpty? ''
        : _orderHistoryDetails.appointedDeliveringTime.substring(
        _orderHistoryDetails.appointedDeliveringTime.indexOf(' ')
    );
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Divider(),
          Padding(padding: EdgeInsets.only(top: 16),),
          _textValuePair('発送準備完了時間', endingTime),
          _textValuePair('対応デバイス名', _orderHistoryDetails.lockedName),
          _textValuePair('発送予定時間', deliveryTime),
          _textValuePair(
              locale.txtNumberOfPieces, _orderHistoryDetails.qrCodeCount.toString()
          ),
          _textValuePair(
              locale.txtReceiptNumber, _orderHistoryDetails.receiptNo.toString()
          ),
        ],
      ),
    );
  }

  _orderInfoBuilder() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(padding: EdgeInsets.only(top: 16.0),),
          _textValuePair(locale.txtOrderNumber, widget.orderItem.orderId.toString()),
          Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CommonWidget.sectionTitleBuilder(locale.txtProductList),
                Divider(thickness: 1.2,),
              ],
            )
          ),
        ],
      ),
    );
  }

  _pickingListBuilder() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          final item = _orderHistoryDetails.products[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: <Widget>[
                PackingProductItem(product: item, onPressed: null,),
                Divider(thickness: 1.2,),
              ],
            )
          );
        },
        childCount: _orderHistoryDetails.products.length,
      ),
    );
  }

  _shippingInfoBuilder() {
    return SliverList(
      delegate: SliverChildListDelegate([
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: CommonWidget.sectionTitleBuilder(locale.txtDeliveryNumber),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(_orderHistoryDetails.baggageControlNumber.toString()),
                    )
                  ],
                ),
                Spacer(),
                Container(
                  height: 32.0,
                  child: widget.historyType == HistoryType.STOCK_OUT
                      ? null : GradientButton(
                    text: locale.txtAddQrCode,
                    onPressed: () => _addNewQrCode(),
                    showIcon: true,
                    icon: const Icon(Icons.add, color: Colors.white,),
                    borderRadius: 25.0,
                    padding: EdgeInsets.symmetric(horizontal: 10.0,),
                  ),
                ),
              ],
            )
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: CommonWidget.sectionTitleBuilder(locale.txtQRScannedLabeledCount),
          ),
        ],
      ),
    );
  }

  _qrCodeListBuilder() {
    final qrCodes = List();
    qrCodes.addAll(_orderHistoryDetails.qrCodes);
    qrCodes.removeWhere(
            (element) => element == null || element == 'null' || element.isEmpty
    );
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          final item = qrCodes[index];
          return Container(
            height: 32,
            margin: EdgeInsets.symmetric(horizontal: 16,),
            child: Row(
              children: <Widget>[
                Text(
                  item,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500
                  ),
                ),
                Visibility(
                  child: IconButton(
                    icon: AppIcons.icDelete,
                    onPressed: () => _confirmDeleteQrCode(item, index == 0),
                  ),
                  visible: widget.historyType == HistoryType.PLANNING,
                ),
              ],
            ),
          );
        },
        childCount: qrCodes.length,
      ),
    );
  }

  _buildBodyItemList() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Visibility(
            child: _sectionTitleBuilder(locale.txtShippingPreparationInfo),
            visible: widget.historyType != HistoryType.STOCK_OUT,
          ),
        ),
        widget.historyType == HistoryType.STOCK_OUT? SliverPadding(
          padding: EdgeInsets.only(top:  0.0),
        ) : _shippingInfoBuilder(),
        widget.historyType == HistoryType.STOCK_OUT? SliverPadding(
          padding: EdgeInsets.only(top:  0.0),
        ) : _qrCodeListBuilder(),
        widget.historyType == HistoryType.STOCK_OUT? SliverPadding(
          padding: EdgeInsets.only(top:  0.0),
        ) : _deliveryInfoBuilder(),
        SliverToBoxAdapter(
          child: _sectionTitleBuilder(locale.txtOrderInfo),
        ),
        _orderInfoBuilder(),
        /*SliverToBoxAdapter(
          child: _sectionTitleBuilder(locale.txtPickingInfo),
        ),*/
        _pickingListBuilder(),
      ],
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
      child: _buildBodyItemList(),
      controller: _refreshController,
      onRefresh: () => _fetchData(),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: Container(
            padding: EdgeInsets.only(left: 13, top: 12, bottom: 12, right: 4,),
            child: InkWell(
              child: AppImages.loadSizedImage(AppImages.icBackToPreviousUrl,),
              onTap: () => Navigator.of(context).pop(),
            )
        ),
        title: Text(locale.txtHistoryDetails),
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
    params[Params.ORDER_ID] = widget.orderItem.orderId;

    String url = HttpUtil.GET_HISTORY_DETAILS;
    if(widget.historyType == HistoryType.STOCK_OUT)
      url = HttpUtil.GET_HISTORY_STOCK_OUT_DETAILS;
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

    LoadingState newState = LoadingState.NO_DATA;
    final data = responseMap[Params.DATA];
    if(widget.historyType == HistoryType.STOCK_OUT) {
      List products = data.map((data) => ProductEntity.fromJson(data)).toList();
      if (products != null) {
        _orderHistoryDetails.products = products;
        _orderHistoryDetails.products.removeWhere(
                (product) => !(product is ProductEntity)
                || product.title == null
                || product.title.isEmpty);
        newState = LoadingState.OK;
      }
    } else {
      _orderHistoryDetails = OrderHistoryDetails.fromJson(data);
//    _orderHistoryDetails = OrderHistoryDetails.dummyOrderHistoryDetailsResponse();
      if (_orderHistoryDetails != null) {
        _orderHistoryDetails.products.removeWhere(
                (product) => !(product is ProductEntity)
            || product.title == null
            || product.title.isEmpty);
        newState = LoadingState.OK;
      }
    }

    setState(() => loadingState = newState);
  }

  _updateReceiptNumber() {
    InputReceiptNumberDialog(
        context,
        locale.txtInputReceiptNumber,
        locale.txtUpdateReceiptNumber, (code) {
      if (code.isNotEmpty && code.toString().length == 4) {
        Navigator.of(context).pop();
        setState(() => _orderHistoryDetails.receiptNo = int.parse(code));
        ToastUtil.show(context, locale.txtReceiptNumberUpdated);
      }
    }).show();
  }

  _addNewQrCode() async {
    final resultList = await Navigator.of(context).push(
        MaterialPageRoute<List<String>>(builder: (BuildContext context) {
          return FullScreenAddQrCodeDialog(
            orderHistoryDetails: _orderHistoryDetails,
          );
        },
        fullscreenDialog: true
    ));

    if (resultList != null && resultList.isNotEmpty) {
      _orderHistoryDetails.qrCodes.addAll(resultList);
    }
    _fetchData();
  }

  _confirmDeleteQrCode(String qrCode, bool isPrimary) {
    if(_orderHistoryDetails.qrCodeCount == 1) {
      _showSnackBar('先に変更後のQRコードを追加してください');
      return;
    }
    String msg = isPrimary? locale.msgPrimaryQrCodeDelete : locale.msgQrCodeDelete;
    msg += '\n\n${locale.txtBaggageNumber}\n$qrCode';
    ConfirmationDialog(
        context,
        locale.txtConfirm,
        msg,
        locale.txtOk, () => _deleteQrCode(qrCode, isPrimary),
    ).show();
  }

  _deleteQrCode(String qrCode, bool isPrimary) async {
    final isDeleted = await Navigator.of(context).push(
        MaterialPageRoute<bool>(builder: (BuildContext context) {
          return QrCodeDeleteDialog(_orderHistoryDetails, qrCode, isPrimary);
        }, fullscreenDialog: true)
    );

    if (isDeleted != null && isDeleted) {
      setState(() => _orderHistoryDetails.qrCodes.remove(qrCode));
    }
    _fetchData();
  }

  _showSnackBar(
      String msg, {
        error = true,
      }) {
    final icon = AppIcons.loadIcon (
        error? AppIcons.icError : AppIcons.icLike, color: Colors.white, size: 16.0
    );
    SnackbarUtil.show(
        context, msg, durationInSec: 3, icon: icon,
        background: error? AppColors.colorAccent : AppColors.colorBlue
    );
  }
}