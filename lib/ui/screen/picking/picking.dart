import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/choice/choice.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/product/product_entity.dart';
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
import 'package:o2o/util/lib/remote/http_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

/// Created by mdhasnain on 31 Jan, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Show the picking and picked product list
/// 2. Scan product with barcode scanner
/// 3. Add new product after checking the barcode on server
/// 4. Check the missing product status

class PickingScreen extends StatefulWidget {
  PickingScreen({
    Key key,
    @required this.orderItem,
    @required this.isUnderWork
  }) : super(key: key);
  final OrderItem orderItem;
  final bool isUnderWork;

  @override
  _PickingScreenState createState() =>
      _PickingScreenState(orderItem, isUnderWork);
}

class _PickingScreenState extends BaseState<PickingScreen>
    with TickerProviderStateMixin {

  _PickingScreenState(this._orderItem, this._isUnderWork);
  final OrderItem _orderItem;
  bool _isUnderWork;
  /// Two different list to separate the picking and picked products
  List<ProductEntity> _scannedProducts = List();
  List _scanCompletedProducts = List();

  final _refreshController = RefreshController(initialRefresh: true);

  /// Option menus : (a) Report Missing (2) Manual JanCode input
  List<Choice> _choices = List();
  Choice _selectedChoice;
  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
    });

    if(_selectedChoice == _choices[1]) _checkMissingInformation();
    else if (_selectedChoice == _choices[2]) _customJANCodeInput();
  }

  /// Initialize the menu items
  void _initChoices() {
    _choices.clear();
    _choices.add(Choice(title: locale.txtSettings, icon: Icons.settings));
    _choices.add(Choice(title: locale.txtReportStorage, icon: Icons.report));
    _choices.add(Choice(title: locale.txtInsertCodeManually, icon: Icons.edit));

    _selectedChoice = _choices[0];
  }

  /// Barcode scanner properties
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'BARCODE');
  var _qrText = "";
  QRViewController _controller;
  bool _flashOn = false;

  /// Barcode scanner widget with fullscreen, flush buttons
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

  /// Title widget for picked and picking product list
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

  /// Providing same type of Text widget from one place
  _boldTextBuilder(String text, double size) {
    return Text(
      text,
      style: TextStyle(
          fontSize: size, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  /// Widget for the Barcode scanner label
  _sectionScannerLabelBuilder() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.blueGradient)
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      alignment: Alignment.center,
      child: _boldTextBuilder(locale.msgScanBarcode, 14),
    );
  }

  /// Checking the missing status of the products
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

  /// Custom input for JAN Code
  _customJANCodeInput() {
    InputDialog(context, locale.titleInsertCodeManually, locale.txtEntryJANCode,
            (code) {
          if (code.isNotEmpty) {
            Navigator.of(context).pop();
            _checkJanCodeProduct(code);
          }
        }).show();
  }

  /// Create the lists of picked and picking products
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
              final item = _scannedProducts[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey,),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ScannedProductItem(
                  scannedProduct: item,
                  onPressed: () => _selectNextStep(),
                  onChangeQuantity:
                      () => _getProductPickingCount(item),
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
                  onPressed: () => _checkPickingStatus(),
                ),
              );
            },
            childCount: _scanCompletedProducts.length + 1,
          ),
        ),
      ],
    );
  }

  /// This the body widget of the 'PickingScreen'
  /// There are several checks inside it based on 'loadingState'
  /// 1. If the there is error on api response the error screen is showed
  /// 2. If the api returns no data then no data screen is showed
  /// 3. Finally if we get data then a List is showed with a PullToRefresh widget
  /// and a barcode scanner is shown on the top of the screen
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
          _sectionScannerLabelBuilder(),
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              header: ClassicHeader(
                idleText: locale.txtPullToRefresh,
                refreshingText: locale.txtRefreshing,
                completeText: locale.txtRefreshCompleted,
                releaseText: locale.txtReleaseToRefresh,
              ),
              child: _createLists(),
              controller: _refreshController,
              onRefresh: () => _fetchData(),
            ),
          ),
        ],
      ),
    );
  }

  /// If user press on the back button, show the confirmation popup
  /// and return to order list on confirmation
  Future<bool> _onWillPop() async {
    return (await ConfirmationDialog(
      context,
      locale.txtReturnToOrderList,
      locale.msgReturnToOrderList,
      locale.txtReturnToTheList,
          () => Navigator.of(context).pop(),
    ).show()) ?? false;
  }

  /// 1. Fetch the data list for the first time
  /// 2. Pause the barcode scanner initially
  @override
  void initState() {
    super.initState();
    //_fetchData();
    _pauseCamera();
  }

  /// Main building block of the screen
  /// 1. 'TopBar' is a custom app bar for showing custom navigation icon,
  /// custom title and custom menu
  /// 2. WillPopScope is for detecting the back button press
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
          onTapNavigation: () => _onWillPop(),
          error: _isUnderWork? '${_orderItem.lockedName}が作業中' : '',
        ),
        backgroundColor: AppColors.colorWhite,
        body: _bodyBuilder(),
      ),
    );
  }

  /// Attach controller with the barcode scanner when the scanner is created
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

  /// Function for toggle the flush of the barcode scanner
  void _toggleFlush() {
    _controller?.toggleFlash();
    setState(() => _flashOn = !_flashOn);
  }

  /// Function for pause the camera of the barcode scanner
  void _pauseCamera() {
    _controller?.pauseCamera();
  }

  /// Function for resume the camera of the barcode scanner
  void _resumeCamera() {
    _controller?.resumeCamera();
  }

  /// This is an async function to fetch product list from the server
  /// It reads the imei from the SharedPreferences and try to send it to
  /// server along with the 'orderNo' of the _orderItem using the api
  /// 'GET_PICKING_LIST'.
  /// Then it checks the response for valid/invalid response code and update
  /// the state with new data
  _fetchData() async {
    //if (loadingState == LoadingState.LOADING) return;

    //setState(() => loadingState = LoadingState.LOADING);

    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final params = HashMap();
    params['imei'] = imei;
    params['orderId'] = _orderItem.orderId;

//    final response = await HttpUtil.get(HttpUtil.GET_PICKING_LIST, params: params);
//    _refreshController.refreshCompleted();
//    if (response.statusCode != HttpCode.OK) {
//      setState(() => loadingState = LoadingState.ERROR);
//      return;
//    }
//
//    final responseMap = json.decode(response.body);
//    final code = responseMap['code'];
//    if(code == HttpCode.NOT_FOUND) {
//      setState(() => loadingState = LoadingState.ERROR);
//      return;
//    }
//    final List data = responseMap['data'];
//    List<ProductEntity> items = data.map(
//            (data) => ProductEntity.fromJson(data)
//    ).toList();
    List<ProductEntity> items = ProductEntity.dummyProducts();

    LoadingState newState = LoadingState.NO_DATA;
    if (_scanCompletedProducts.isNotEmpty || items.isNotEmpty) {
      _scanCompletedProducts.clear();
      _scannedProducts.clear();
      items.forEach((item) {
        if (item.itemCount == item.pickedItemCount)
          _scanCompletedProducts.add(item);
        else
          _scannedProducts.add(item);
      });

      newState = LoadingState.OK;
    }

    setState(() => loadingState = newState);
    _checkPickingStatus();
  }

  /// If user wants to use a fullscreen scanner this function provides that.
  /// A fullscreen function is popped up and this function waits for the
  /// scan result of the scanner. If the scanner finds a barcode
  /// this function calls '_checkJanCodeProduct' to check that code in server
  void _fullScreenScanner() async {
    final results = await Navigator.of(context).push(
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => ScannerScreen(
              navigationIcon: AppIcons.loadIcon(
                  AppIcons.icBackToList,
                  size: 48.0,
                  color: Colors.white
              ),
              menu: PopupMenuButton(
                child: AppIcons.loadIcon(
                    AppIcons.icSettings, size: 48.0, color: Colors.white
                ),
                onSelected: _select,
                itemBuilder: (BuildContext context) {
                  return _choices.skip(1).map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                }),
              onTapNavigation: () => Navigator.of(context).pop(),
            ),
            fullscreenDialog: true
        )
    );

    _resumeCamera();
    if (results != null && results.containsKey('qrCode')) {
      setState(() {
        _qrText = results['qrCode'];
      });
      _checkJanCodeProduct(_qrText);
    }
  }

  /// This function checks the provided janCode in the server and if a valid
  /// product is found it calls '_getProductPickingCount' function to popup
  /// new product add dialog
  /// The result of the api check can be
  /// 1. No product found for the janCode
  /// 2. The product is already picked
  /// 3. New product
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
    final params = HashMap();
    params['imei'] = imei;
    params['orderId'] = _orderItem.orderId;
    params['janCode'] = janCode;

    final response = await HttpUtil.get(HttpUtil.CHECK_PICKED_ITEM, params: params);
    Navigator.of(context).pop();
    if (response.statusCode != 200) {
      ToastUtil.show(
          context, locale.errorServerIsNotAvailable,
          icon: Icon(Icons.error, color: Colors.white,),
          fromTop: true, verticalMargin: 110, error: true
      );
      _resumeCamera();
      return;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap['code'];
    final msg = responseMap['msg'];
    if(code != PickingCheckStatus.NOT_PICKED) {
      ToastUtil.show(
          context, msg,
          icon: Icon(Icons.error, color: Colors.white,),
          fromTop: true, verticalMargin: 110, error: true
      );
      _resumeCamera();
      return;
    }
    final data = responseMap['data'];
    ProductEntity product = ProductEntity.fromJson(data);

    _getProductPickingCount(product);
  }

  /// The function shows 'AddProductDialog' popup to get the picking count.
  /// After getting the picking it calls '_updateProductPickingCount' function
  /// with the count to update in the server
  _getProductPickingCount(ProductEntity product) {
//    if(_scanCompletedProducts.firstWhere(
//            (element) => element.janCode.toString() == janCode,
//        orElse: () {
//          print('Product not picked for $janCode');
//        }
//    ) != null) {
//      ToastUtil.show(context, 'Product already picked with $janCode');
//      _resumeCamera();
//      return;
//    }
//    final product = _scannedProducts.firstWhere(
//            (element) => element.janCode.toString() == janCode, orElse: () {
//      ToastUtil.show(context, 'No product with $janCode');
//      _resumeCamera();
//      return;
//    });

    if(product == null) return;

    AddProductDialog(context, product, (int pickCount) {
      Navigator.of(context).pop();
      if(pickCount > 0)
        _updateProductPickingCount(product, pickCount);
    }).show();
  }

  /// After 'AddProductDialog' this function is called to add the new product to
  /// the server. If successfully added to the server, do the following
  /// 1. If the picking count is less that itemCount add to the picking list
  /// 2. If equal, add to the picked list and remove from the picking list
  /// Finally, Update the state with the new data
  _updateProductPickingCount(ProductEntity product, int pickCount) async {

    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final params = HashMap();
    params['imei'] = imei;
    params['orderId'] = _orderItem.orderId;
    params['janCode'] = product.janCode;
    params['pickingCount'] = pickCount;

    final response = await HttpUtil.post(HttpUtil.UPDATE_PICKING_COUNT, params);
    if (response.statusCode != HttpCode.OK) {
      ToastUtil.show(context, locale.errorServerIsNotAvailable,);
      _resumeCamera();
      return;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap['code'];
    final msg = responseMap['msg'];
    if(code != HttpCode.OK) {
      ToastUtil.show(
          context, msg,
          icon: Icon(Icons.error, color: Colors.white,),
          fromTop: true, verticalMargin: 110, error: true
      );
      _resumeCamera();
      _fetchData();
      return;
    }
//    final data = responseMap['data'];
//    if(product.itemCount == product.pickedItemCount) {
//      setState(() {
//        _scannedProducts.remove(product);
//        _scanCompletedProducts.add(product);
//      });
//    }

    ToastUtil.show(context, 'Product picked');
    _resumeCamera();
    _checkPickingStatus();
    _fetchData();
  }

  /// After every picking action check if all items are picked
  /// If picked, popup to go to packing or select another odder
  _checkPickingStatus() {
    if(_scannedProducts.isEmpty && _scanCompletedProducts.isNotEmpty) {
      _selectNextStep();
    }
  }

  /// Select next step when all product's picking is complete.
  /// Total three options
  /// 1. Start packing -> Update picking status and ask for starting packing
  /// 2. Check missing order -> Check missing order
  /// 3. Start picking for another order -> Go back to order list screen
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
          _completePickingAndConfirmationForPacking();
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

  /// This function uses 'UPDATE_PICKING_STATUS' api to update the picking
  /// status as done and show the confirmation dialog to start packing
  _completePickingAndConfirmationForPacking() async {
    CommonWidget.showLoader(context, cancelable: true);
    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final params = HashMap();
    params['imei'] = imei;
    params['orderId'] = _orderItem.orderId;
    params['status'] = PickingStatus.DONE;

    var response = await HttpUtil.post(HttpUtil.UPDATE_PICKING_STATUS, params);
    Navigator.of(context).pop();
    if (response.statusCode != HttpCode.OK) {
      ToastUtil.show(context, locale.errorServerIsNotAvailable,);
      return;
    }

    ConfirmationDialog(
        context,
        locale.txtStartShippingPreparation,
        locale.msgStartPicking,
        locale.txtStart, () => _startPackingForResult()
    ).show();
  }

  /// Start packing when all items are picked.
  /// First change the packing status of the order as working
  /// Then Go to the packing screen and wait for the result
  _startPackingForResult() async {
    CommonWidget.showLoader(context, cancelable: true);
    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final params = HashMap();
    params['imei'] = imei;
    params['orderId'] = _orderItem.orderId;
    //update packing status as working
    params['status'] = PackingStatus.WORKING;
    var response = await HttpUtil.post(HttpUtil.UPDATE_PACKING_STATUS, params);
    Navigator.of(context).pop();
    if (response.statusCode != 200) {
      ToastUtil.show(context, locale.errorServerIsNotAvailable,);
      return;
    }

    _pauseCamera();
    final results = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PackingScreen(
              orderItem: _orderItem,
              isUnderWork: _isUnderWork,
            )
    ));

    if (results != null && results.containsKey('order_id')) {
      Navigator.of(context).pop(results);
    }
  }

  /// Dispose the controller when the screen is disposed
  @override
  void dispose() {
    _refreshController.dispose();
    _controller?.dispose();
    super.dispose();
  }
}