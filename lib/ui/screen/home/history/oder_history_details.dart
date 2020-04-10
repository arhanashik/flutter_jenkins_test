import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/ui/screen/addqrcode/full_screen_add_qr_code_dialog.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/home/history/order_list_history.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/widget/dialog/input_receipt_number_dialog.dart';
import 'package:o2o/ui/widget/packing_product_item.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';

/// Created by mdhasnain on 07 Feb, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1.
/// 2.
/// 3.

class OrderHistoryDetailsScreen extends StatefulWidget {

  OrderHistoryDetailsScreen(this.title, this.orderItem, this.historyType);

  final String title;
  final OrderItem orderItem;
  final HistoryType historyType;

  @override
  _OrderHistoryDetailsScreenState createState() => _OrderHistoryDetailsScreenState(
    title, orderItem, historyType,
  );
}

class _OrderHistoryDetailsScreenState extends BaseState<OrderHistoryDetailsScreen> {

  _OrderHistoryDetailsScreenState(this._title, this._orderItem, this._historyType);

  final String _title;
  final OrderItem _orderItem;
  final HistoryType _historyType;

  String _receiptNumber = '1234';
  List _products = List();
  List<String> _qrCodes = List();
  _fetchProducts() {
    _products.addAll(ProductEntity.dummyProducts());

    _qrCodes.add('111-222-333-444');
    _qrCodes.add('333-444-555-666');
    _qrCodes.add('666-777-888-999');

    setState(() => loadingState = LoadingState.OK);
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

  _sectionLeftBorderTextBuilder(text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 3.0,
          height: 18.0,
          margin: EdgeInsets.only(right: 10.0),
          decoration: BoxDecoration(
            color: AppColors.colorBlue,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
        ),
        Text(
          text,
          style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

  _textButtonPair(
      text,
      btnTxt,
      onPress,
      btnVisibility, {
        showIcon = false,
        icon = const Icon(Icons.add, color: Colors.white,),
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      height: 48.0,
      child: Row(
        children: <Widget>[
          Text(
            text,
            style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          Spacer(),
          Visibility(
            child: GradientButton(
              text: btnTxt,
              onPressed: () => onPress(),
              showIcon: showIcon,
              icon: icon,
              borderRadius: 25.0,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            ),
            visible: btnVisibility,
          ),
        ],
      ),
    );
  }

  _deliveryInfoBuilder() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Divider(),
          Padding(padding: EdgeInsets.only(top: 16),),
          _textValuePair('発送準備完了時間', '12:45'),
          _textValuePair('対応デバイス名', 'xxxx'),
          _textValuePair('発送予定時間', '1３:00'),
//          _textValuePair(
//              _historyType == HistoryType.COMPLETE
//                  ? locale.txtShippingTime : locale.txtShippingPlanTime, '13:00'
//          ),
          _textValuePair(locale.txtNumberOfPieces, _orderItem.productCount.toString()),
          _textValuePair(locale.txtReceiptNumber, _receiptNumber),
        ],
      ),
    );
  }

  _orderInfoBuilder() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(padding: EdgeInsets.only(top: 16.0),),
          _textValuePair(locale.txtOrderNumber, _orderItem.orderId.toString()),
          Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0,),
            child: _sectionLeftBorderTextBuilder(locale.txtProductList,),
          ),
          Divider(thickness: 1.0,),
        ],
      ),
    );
  }

  _pickingListBuilder() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: PackingProductItem(
              product: _products[index],
              onPressed: null,
            ),
          );
        },
        childCount: _products.length,
      ),
    );
  }

  _shippingInfoBuilder() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: <Widget>[
                _sectionLeftBorderTextBuilder(
                  '${locale.txtDeliveryNumber}\n4444',
                ),
                Spacer(),
                Visibility(
                  child: GradientButton(
                    text: locale.txtAddQrCode,
                    onPressed: () => _addNewQrCode(),
                    showIcon: true,
                    icon: const Icon(Icons.add, color: Colors.white,),
                    borderRadius: 25.0,
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  ),
                  visible: _historyType != HistoryType.MISSING,
                )
              ],
            )
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _sectionLeftBorderTextBuilder(
              locale.txtQRScannedLabeledCount,
            ),
          ),
        ],
      ),
    );
  }

  _deleteQrCode(String qrCode, bool isPrimary) {
    String msg = isPrimary? locale.msgPrimaryQrCodeDelete : locale.msgQrCodeDelete;
    msg += '\n\n${locale.txtQrCodeNumber}\n$qrCode';
    ConfirmationDialog(
      context,
      locale.txtConfirm,
      msg,
      locale.txtOk,
      () {
        setState(() => _qrCodes.remove(qrCode));
        ToastUtil.show(
          context, 'QRコード: $qrCodeを削除しました。',
        );
      }
    ).show();
  }

  _qrCodeListBuilder() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          return Container(
            height: 32,
            margin: EdgeInsets.symmetric(horizontal: 16,),
            child: Row(
              children: <Widget>[
                Text(
                  _qrCodes[index],
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500
                  ),
                ),
                Spacer(),
                Visibility(
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteQrCode(_qrCodes[index], index == 0),
                  ),
                  visible: _historyType == HistoryType.PLANNING,
                ),
              ],
            ),
          );
        },
        childCount: _qrCodes.length,
      ),
    );
  }

  _updateReceiptNumber() {
    InputReceiptNumberDialog(
        context,
        locale.txtInputReceiptNumber,
        locale.txtUpdateReceiptNumber, (code) {
          if (code.isNotEmpty && code is String && code.length == 4) {
            Navigator.of(context).pop();
            setState(() => _receiptNumber = code);
            ToastUtil.show(context, locale.txtReceiptNumberUpdated);
          }
        }).show();
  }

  _addNewQrCode() async {
    final resultList = await Navigator.of(context).push(new MaterialPageRoute<List<String>>(
        builder: (BuildContext context) {
          return FullScreenAddQrCodeDialog(orderItem: _orderItem, qrCodes: _qrCodes,);
        },
        fullscreenDialog: true
    ));

    if (resultList != null) {
      List<String> newCodes = List();
      if(resultList.length > _qrCodes.length) {
        newCodes = resultList.where((element) => !_qrCodes.contains(element)).toList();
      } else {
        newCodes = _qrCodes.where((element) => !resultList.contains(element)).toList();
      }

      if(newCodes.isNotEmpty) {
        setState(() => _qrCodes = resultList);
        ToastUtil.show(
          context, 'QRコード: ${newCodes.join(', ')}を追加しました。',
        );
      }
    }
  }

  _bodyBuilder() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Visibility(
            child: _sectionTitleBuilder(locale.txtShippingPreparationInfo),
            visible: _historyType != HistoryType.MISSING,
          ),
        ),
        _historyType == HistoryType.MISSING? SliverPadding(
          padding: EdgeInsets.only(top:  0.0),
        ) : _shippingInfoBuilder(),
        _historyType == HistoryType.MISSING? SliverPadding(
          padding: EdgeInsets.only(top:  0.0),
        ) : _qrCodeListBuilder(),
        _historyType == HistoryType.MISSING? SliverPadding(
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
        SliverPadding(padding: EdgeInsets.only(bottom: 16),)
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(locale.txtHistoryDetails),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(38.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.blueGradient),
            ),
            alignment: Alignment.center,
            child: Text(
              _title,
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ),
      body: _bodyBuilder(),
    );
  }
}