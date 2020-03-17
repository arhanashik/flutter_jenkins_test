import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/choice/choice.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/data/response/PickedItemCheckResponse.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/error/error.dart';
import 'package:o2o/ui/screen/packing/packing.dart';
import 'package:o2o/ui/screen/scanner/scanner.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/common/topbar.dart';
import 'package:o2o/ui/widget/dialog/add_product_dialog.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/widget/dialog/full_screen_missing_information_checker_dialog.dart';
import 'package:o2o/ui/widget/dialog/input_dialog.dart';
import 'package:o2o/ui/widget/dialog/select_next_step_dialog.dart';
import 'package:o2o/ui/widget/scanned_product_item.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/HttpUtil.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class PickingScreen extends StatefulWidget {
  final OrderItem orderItem;

  PickingScreen({Key key, this.orderItem}) : super(key: key);

  @override
  _PickingScreenState createState() =>
      _PickingScreenState(orderItem);
}

class _PickingScreenState extends BaseState<PickingScreen>
    with TickerProviderStateMixin {

  _PickingScreenState(this._orderItem);
  final OrderItem _orderItem;
  
  List<ProductEntity> _scannedProducts = List();
  List _scanCompletedProducts = List();

  List<Choice> _choices = List();
  Choice _selectedChoice;
  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
    });

    if(_selectedChoice == _choices[1]) _checkMissingInformation();
    else if (_selectedChoice == _choices[2]) _customJANCodeInput();
  }

  void _initChoices() {
    _choices.clear();
    _choices.add(Choice(title: locale.txtSettings, icon: Icons.settings));
    _choices.add(Choice(title: locale.txtReportStorage, icon: Icons.report));
    _choices.add(Choice(title: locale.txtInsertCodeManually, icon: Icons.edit));

    _selectedChoice = _choices[0];
  }

  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  var _qrText = "";
  QRViewController _controller;
  bool _flashOn = false;

  _sectionBarcodeScanner() {
    return Container(
      constraints: BoxConstraints.expand(height: 220),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
//            color: Colors.lightBlue,
            child: QRView(
              key: _qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Container(
            height: 65,
            margin: EdgeInsets.only(right: 10, bottom: 10),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Icon(
                      _flashOn ? Icons.flash_off : Icons.flash_on,
                      color: Colors.lightBlue,
                    ),
                    padding: EdgeInsets.all(2),
                  ),
                  onTap: _toggleFlush,
                ),
                Spacer(),
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Icon(
                      Icons.fullscreen,
                      color: Colors.lightBlue,
                    ),
                    padding: EdgeInsets.all(2),
                  ),
                  onTap: _fullScreenScanner,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _sectionTitleBuilder(title) {
    return Container(
      margin: EdgeInsets.only(left: 16, top: 16),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(width: 3.0, color: Colors.lightBlue)),
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

  _boldTextBuilder(String text, double size) {
    return Text(
      text,
      style: TextStyle(
          fontSize: size, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  _sectionHeaderBuilder(String text) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.blueGradient)
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      alignment: Alignment.center,
      child: _boldTextBuilder('$text', 14),
    );
  }

  _checkMissingInformation() async {
    FullScreenMissingInformationCheckerDialog(items: _scannedProducts,);

    final resultList = await Navigator.of(context).push(new MaterialPageRoute<List>(
        builder: (BuildContext context) {
          return FullScreenMissingInformationCheckerDialog(items: _scannedProducts,);
        },
        fullscreenDialog: true
    ));

    if (resultList != null) {
      ToastUtil.show(
        context, '商品を削除しました。', icon: Icon(Icons.close,),
      );
      Navigator.of(context).pop();
    }
  }

  _customJANCodeInput() {
    InputDialog(context, locale.titleInsertCodeManually, locale.txtEntryJANCode,
            (code) {
          if (code.isNotEmpty) {
            Navigator.of(context).pop();
            _checkJanCodeProduct(code);
          }
        }).show();
  }

  _selectNextStep() {
    SelectNextStepDialog(
        context: context,
        title: locale.txtAllProductsPickingDone,
        msg: locale.txtSelectNextStep,
        warning: locale.txtProvideMissingInfo,
        confirmBtnTxt: locale.txtProceedToShippingPreparation,
        otherButtonText: locale.txtPickAnotherOrder,
        onConfirm: () {
          Navigator.of(context).pop();
          ConfirmationDialog(
            context,
            locale.txtStartShippingPreparation,
            locale.msgStartPicking,
            locale.txtStart, () => _startPackingForResult()
          ).show();
        },
        onReportMissing: () {
          Navigator.of(context).pop();
          _checkMissingInformation();
        },
        onOther: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
    ).show();
  }

  _startPackingForResult() async {
    //update picking status as done
//    String imei = await PrefUtil.read(PrefUtil.IMEI);
//    final requestBody = HashMap();
//    requestBody['imei'] = imei;
//    requestBody['orderNo'] = _orderItem.orderNo;
//    requestBody['status'] = PickingStatus.DONE;
//
//    var response = await HttpUtil.postReq(AppConst.UPDATE_PICKING_STATUS, requestBody);
//    print('code: ${response.statusCode}');
//    if (response.statusCode != 200) {
//      ToastUtil.showCustomToast(context, 'Failed to upate picking status');
//      return;
//    }
//
//    //update packing status as working
//    requestBody['status'] = PackingStatus.WORKING;
//    response = await HttpUtil.postReq(AppConst.UPDATE_PACKING_STATUS, requestBody);
//    print('code: ${response.statusCode}');
//    if (response.statusCode != 200) {
//      ToastUtil.showCustomToast(context, 'Failed to upate packing status');
//      return;
//    }

    _pauseCamera();
    final results = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PackingScreen(
              orderItem: _orderItem,
            )
    ));

    if (results != null && results.containsKey('order_id')) {
      Navigator.of(context).pop(results);
    }
  }

  _createLists() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Visibility(
              child: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _sectionTitleBuilder(locale.txtScannedProduct),
              ),
            visible: _scannedProducts.isNotEmpty,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey,),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ScannedProductItem(
                  scannedProduct: _scannedProducts[index],
                  onPressed: () => _selectNextStep(),
                ),
              );
            },
            childCount: _scannedProducts.length,
          ),
        ),
        SliverToBoxAdapter(
          child: Visibility(
            child: Padding(
              padding: EdgeInsets.only(top: 16, bottom: 10),
              child: _sectionTitleBuilder(locale.txtScanCompletedProduct),
            ),
            visible: _scanCompletedProducts.isNotEmpty,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (index == _scanCompletedProducts.length)
                return CommonWidget.buildProgressIndicator(loadingState);
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.colorF1F1F1,
                  border: Border.all(color: Colors.grey,),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ScannedProductItem(
                  scannedProduct: _scanCompletedProducts[index],
                  onPressed: null,
                ),
              );
            },
            childCount: _scanCompletedProducts.length + 1,
          ),
        ),
      ],
    );
  }

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

    ): Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionBarcodeScanner(),
          _sectionHeaderBuilder(locale.msgScanBarcode),
          Expanded(
            child: _createLists(),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await ConfirmationDialog(
      context,
      locale.txtReturnToOrderList,
      locale.msgReturnToOrderList,
      locale.txtReturnToTheList,
          () => Navigator.of(context).pop(),
    ).show()) ?? false;
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _pauseCamera();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _initChoices();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: TopBar (
          title: '',
          navigationIcon: AppIcons.loadIcon(
              AppIcons.icBackToList, size: 48.0, color: Colors.white
          ),
          iconColor: Colors.white,
          background: Colors.transparent,
          menu: PopupMenuButton(
                child: AppIcons.loadIcon(AppIcons.icSettings, size: 48.0, color: Colors.white),
                onSelected: _select,
                itemBuilder: (BuildContext context) {
                  return _choices.skip(1).map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                }),
          onTapNavigation: () { _onWillPop();},
        ),
//        appBar: AppBar(
//          title: Text(''),
//          centerTitle: true,
//          backgroundColor: Colors.transparent,
//          iconTheme: IconThemeData(color: Colors.white),
//          actions: <Widget>[
//            PopupMenuButton(
//                icon: Icon(_choices[0].icon),
//                onSelected: _select,
//                itemBuilder: (BuildContext context) {
//                  return _choices.skip(1).map((Choice choice) {
//                    return PopupMenuItem<Choice>(
//                      value: choice,
//                      child: Text(choice.title),
//                    );
//                  }).toList();
//                }),
//          ],
//        ),
        backgroundColor: AppColors.colorWhite,
        body: _bodyBuilder(),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this._controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _qrText = scanData;
      });
      _pauseCamera();
      _checkJanCodeProduct(_qrText);
    });
  }

  void _toggleFlush() {
    _controller?.toggleFlash();
    setState(() => _flashOn = !_flashOn);
  }

  void _pauseCamera() {
    _controller?.pauseCamera();
  }

  void _resumeCamera() {
    _controller?.resumeCamera();
  }

  _fetchData() async {
    if (loadingState == LoadingState.LOADING) return;

    setState(() => loadingState = LoadingState.LOADING);

//    String imei = await PrefUtil.read(PrefUtil.IMEI);
//    final requestBody = HashMap();
//    requestBody['imei'] = imei;
//    requestBody['orderNo'] = _orderItem.orderNo;
//
//    final response = await HttpUtil.postReq(AppConst.GET_PICKING_LIST, requestBody);
//    print('code: ${response.statusCode}');
//    if (response.statusCode != 200) {
//      setState(() => loadingState = LoadingState.ERROR);
//      return;
//    }
//
//    print('body: ${response.body}');
//    List jsonData = json.decode(response.body);
//    List<ProductEntity> items = jsonData.map(
//            (data) => ProductEntity.fromJson(data)
//    ).toList();
    List<ProductEntity> items = ProductEntity.dummyProducts();

    LoadingState newState = LoadingState.NO_DATA;
    if (_scanCompletedProducts.isNotEmpty || items.isNotEmpty) {
      items.forEach((item) {
        if (item.itemCount == item.pickedItemCount)
          _scanCompletedProducts.add(item);
        else
          _scannedProducts.add(item);
      });

      newState = LoadingState.OK;
    }

    setState(() => loadingState = newState);
  }

  void _fullScreenScanner() async {
    final results = await Navigator.of(context).push(
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => ScannerScreen(
              navigationIcon: AppIcons.loadIcon(
                  AppIcons.icBackToList,
                  size: 64.0,
                  color: Colors.white
              ),
              menu: PopupMenuButton(
                child: AppIcons.loadIcon(AppIcons.icSettings, size: 48.0, color: Colors.white),
                onSelected: _select,
                itemBuilder: (BuildContext context) {
                  return _choices.skip(1).map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                }),
              onTapNavigation: () { _onWillPop();},
            ),
            fullscreenDialog: true
        )
    );

    if (results != null && results.containsKey('qrCode')) {
      setState(() {
        _qrText = results['qrCode'];
      });
      _checkJanCodeProduct(_qrText);
    }
  }

  _checkJanCodeProduct(janCode) async {
    if(!isOnline) {
      ToastUtil.show(
          context, 'Connect to internet first',
          icon: Icon(Icons.error, color: Colors.white,),
          fromTop: true, verticalMargin: 110, error: true
      );
      _resumeCamera();
      return;
    }

    CommonWidget.showLoader(context, cancelable: true);
    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final requestBody = HashMap();
    requestBody['imei'] = imei;
    requestBody['orderNo'] = _orderItem.orderNo;
    requestBody['janCode'] = janCode;

    final response = await HttpUtil.postReq(AppConst.CHECK_PICKED_ITEM, requestBody);
    print('code: ${response.statusCode}');
    Navigator.of(context).pop();
    if (response.statusCode != 200) {
      ToastUtil.show(
          context, 'Please try again',
          icon: Icon(Icons.error, color: Colors.white,),
          fromTop: true, verticalMargin: 110, error: true
      );
      _resumeCamera();
      return;
    }

    print('body: ${response.body}');
    final pickedResponse = PickedItemCheckResponse.fromJson(
        json.decode(response.body)
    );
    if(pickedResponse.resultCode == PickingCheckStatus.NOT_AVAILABLE) {
      ToastUtil.show(
          context, 'No product with $janCode',
          icon: Icon(Icons.error, color: Colors.white,),
          fromTop: true, verticalMargin: 110, error: true
      );
      _resumeCamera();
      return;
    }

    if(pickedResponse.resultCode == PickingCheckStatus.PICKED) {
      ToastUtil.show(
          context, 'Product already picked with $janCode',
          icon: Icon(Icons.error, color: Colors.white,),
          fromTop: true, verticalMargin: 110, error: true
      );
      _resumeCamera();
      return;
    }

    _getProductPickingCount(janCode);
  }

  _getProductPickingCount(janCode) {
    if(_scanCompletedProducts.firstWhere(
            (element) => element.janCode.toString() == janCode,
        orElse: () {
          print('Product not picked for $janCode');
        }
    ) != null) {
      ToastUtil.show(context, 'Product already picked with $janCode');
      _resumeCamera();
      return;
    }
    final product = _scannedProducts.firstWhere(
            (element) => element.janCode.toString() == janCode, orElse: () {
      ToastUtil.show(context, 'No product with $janCode');
      _resumeCamera();
      return;
    });

    if(product == null) return;

    AddProductDialog(context, product, () {
      Navigator.of(context).pop();
      _updateProductPickingCount(product);
    }).show();
  }

  _updateProductPickingCount(ProductEntity product) async {
    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final requestBody = HashMap();
    requestBody['imei'] = imei;
    requestBody['orderNo'] = _orderItem.orderNo;
    requestBody['janCode'] = product.janCode;
    requestBody['pickingCount'] = product.pickedItemCount;

    final response = await HttpUtil.postReq(AppConst.UPDATE_PICKING_COUNT, requestBody);
    print('code: ${response.statusCode}');
    if (response.statusCode != 200) {
      ToastUtil.show(context, 'Please try again');
      _resumeCamera();
      return;
    }

    setState(() => loadingState = LoadingState.LOADING);
    setState(() {
      if(product.itemCount == product.pickedItemCount) {
        _scannedProducts.remove(product);
        _scanCompletedProducts.add(product);
      }
      loadingState = LoadingState.OK;
    });

    ToastUtil.show(context, 'Product picked');
    _resumeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
