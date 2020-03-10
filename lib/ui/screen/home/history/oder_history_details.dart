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

  _OrderHistoryDetailsScreenState(this.title, this.orderItem, this.historyType);

  final String title;
  final OrderItem orderItem;
  final HistoryType historyType;

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
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.blueGradient),
      ),
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        padding: EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(width: 3.0, color: Colors.white)),
        ),
        child: Text(
          title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  _textValuePair(text, value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
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

  _textButtonPair(text, btnTxt, onPress, btnVisibility) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Row(
        children: <Widget>[
          Text(
            text,
            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          Spacer(),
          Visibility(
            child: GradientButton(
              text: btnTxt,
              onPressed: () => onPress(),
            ),
            visible: btnVisibility,
          ),
        ],
      ),
    );
  }

  _orderInfoBuilder() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          _textValuePair(locale.txtOrderNumber, orderItem.orderNo.toString()),
          _textValuePair(locale.txtPickingCompletionTime, '12:45'),
          _textValuePair(locale.txtUsedDeviceName, '01'),
          _textValuePair(
              historyType == HistoryType.COMPLETE
                  ? locale.txtShippingTime : locale.txtShippingPlanTime, '13:00'
          ),
          _textValuePair(locale.txtNumberOfPieces, orderItem.productCount.toString()),
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
          _textButtonPair(
              '${locale.txtReceiptNumber}\n$_receiptNumber',
              locale.txtModifyReceiptNumber, () => _updateReceiptNumber(),
              historyType != HistoryType.MISSING
          ),
          Divider(height: 3,),
          _textButtonPair(
              '${locale.txtBaggageManagementNumber}\n4444',
              locale.txtAddQrCode,
              () => _addNewQrCode(),
              historyType == HistoryType.PLANNING
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            child: Text(
              locale.txtQRScannedLabeledCount,
              style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          )
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
            margin: EdgeInsets.symmetric(horizontal: 24,),
            child: Row(
              children: <Widget>[
                Text(
                  _qrCodes[index],
                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Spacer(),
                Visibility(
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteQrCode(_qrCodes[index], index == 0),
                  ),
                  visible: historyType == HistoryType.PLANNING,
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
          return FullScreenAddQrCodeDialog(orderItem: orderItem, qrCodes: _qrCodes,);
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
          child: _sectionTitleBuilder(locale.txtOrderInfo),
        ),
        _orderInfoBuilder(),
        SliverToBoxAdapter(
          child: _sectionTitleBuilder(locale.txtPickingInfo),
        ),
        _pickingListBuilder(),
        SliverToBoxAdapter(
          child: _sectionTitleBuilder(locale.txtShippingPreparationInfo),
        ),
        _shippingInfoBuilder(),
        _qrCodeListBuilder(),
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
      backgroundColor: Color.fromARGB(255, 230, 242, 255),
      appBar: AppBar(
        title: Text(locale.txtHistoryDetails),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(32.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.blueGradient),
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ),
      body: _bodyBuilder(),
    );
  }
}