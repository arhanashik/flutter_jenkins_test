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
import 'package:o2o/ui/screen/picking/picking_scanner_overlay_shape.dart';
import 'package:o2o/ui/screen/scanner/scanner.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/common/topbar.dart';
import 'package:o2o/ui/widget/dialog/add_product_dialog.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';
import 'package:o2o/ui/widget/dialog/full_screen_stock_out_dialog.dart';
import 'package:o2o/ui/widget/dialog/input_dialog.dart';
import 'package:o2o/ui/widget/dialog/select_next_step_dialog.dart';
import 'package:o2o/ui/widget/popup/popup_divider.dart';
import 'package:o2o/ui/widget/popup/popup_menu_item.dart';
import 'package:o2o/ui/widget/popup/popup_shape.dart';
import 'package:o2o/ui/widget/scanned_product_item.dart';
import 'package:o2o/ui/widget/snackbar/snackbar_util.dart';
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

class _PickingScreenState extends BaseState<PickingScreen> {

  _PickingScreenState(this._orderItem, this._isUnderWork);
  final OrderItem _orderItem;
  bool _isUnderWork;
  /// Two different list to separate the picking and picked products
  List<ProductEntity> _scannedProducts = List();
  List<ProductEntity> _scanCompletedProducts = List();

  final _refreshController = RefreshController(initialRefresh: true);

  /// Option menus : (a) Report Missing (2) Manual JanCode input
  List<Choice> _choices = List();
  Choice _selectedChoice;
  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
    });

    if(_selectedChoice == _choices[1]) _checkStockOutStatus();
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
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        Container(
          height: 300,
          child: QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: PickingScannerOverlayShape(
              borderColor: AppColors.colorBlue,
              borderRadius: 0,
              borderLength: 13,
              borderWidth: 5,
              cutOutWidth: 180,
              cutOutHeight: 120,
            ),
          ),
        ),
        Container(
          height: 56,
          margin: EdgeInsets.only(right: 10, bottom: 10),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: _flashOn ? AppImages.icFlushOn : AppImages.icFlushOff,
                onTap: _toggleFlush,
              ),
              Spacer(),
              GestureDetector(
                child: AppImages.icFullScreenEnter,
                onTap: _fullScreenScanner,
              ),
            ],
          ),
        )
      ],
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
  _checkStockOutStatus({fromNextStepDialog = false}) async {
    final products = List<ProductEntity>();
    products.addAll(_scannedProducts);
    products.addAll(_scanCompletedProducts);

    final resultList = await Navigator.of(context).push(new MaterialPageRoute<List>(
        builder: (BuildContext context) {
          return FullScreenStockOutDialog(orderItem: _orderItem, products: products,);
        },
        fullscreenDialog: true
    ));

    if (resultList != null) {
      String msg = '欠品のため注文番号：${_orderItem.orderId}...はキャンセルになりました。';
      SnackbarUtil.show(
        context, msg, background: AppColors.colorAccent,
        icon: Icon(Icons.cancel, size: 24, color: Colors.white,),
      );
      Navigator.of(context).pop();
    } else {
      if(fromNextStepDialog) _selectNextStep();
    }
  }

  /// Custom input for JAN Code
  _customJANCodeInput() {
    _pauseCamera();
    InputDialog(context, locale.titleInsertCodeManually, locale.txtEntryJANCode,
            (code) {
          if (code.isNotEmpty) {
            Navigator.of(context).pop();
            _checkJanCodeProduct(code, true);
          }
        }, onCancel: () => _resumeCamera()).show();
  }

  /// Create the lists of picked and picking products
  _createLists() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Visibility(
              child: Padding(
                padding: EdgeInsets.only(left: 16, top: 10,),
                child: CommonWidget.sectionTitleBuilder(locale.txtScannedProduct),
              ),
            visible: _scannedProducts.isNotEmpty,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final item = _scannedProducts[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: ScannedProductItem(
                  scannedProduct: item,
                  onPressed: () {
                    if(_isPickingComplete()) _selectNextStep();
                  },
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
              padding: EdgeInsets.only(left: 16, top: 10,),
              child: CommonWidget.sectionTitleBuilder(locale.txtScanCompletedProduct),
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
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: ScannedProductItem(
                  scannedProduct: _scanCompletedProducts[index],
                  onPressed: () {
                    if(_isPickingComplete()) _selectNextStep();
                  },
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

    ) : Container(
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

  _showMenu(Offset offset) {
    double left = offset.dx;
//    double top = offset.dy + 28;
    double top = _isUnderWork? 100.0 : 74.0;
    showMenu(
        context: context,
        position: RelativeRect.fromLTRB(left, top, 13, 0),
        shape: PopupShape(
            side: BorderSide(color: AppColors.colorBlue),
            borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
//        color: AppColors.colorBlue,
        items: <PopupMenuEntry>[
          MyPopupMenuItem(
            text: locale.txtReportStorage,
            icon: null,
            onTap: () => _checkStockOutStatus(),
          ),
          MyPopupMenuDivider(),
          MyPopupMenuItem(
            text: locale.txtInsertCodeManually,
            icon: Icon(Icons.edit, color: AppColors.colorBlue, size: 18.0,),
            onTap: () => _customJANCodeInput(),
          ),
        ],
    );
  }

//  bool _menuShown = false;
//  _buildMenu() {
//    return Container(
//      color: Colors.white,
//      width: 180.0,
//      child: Column(
//        children: <Widget>[
//          InkWell(
//            child: Padding(
//              child: Text(
//                locale.txtReportStorage,
//                style: TextStyle(
//                    color: AppColors.colorBlueDark,
//                    fontWeight: FontWeight.w600,
//                    fontSize: 14.0
//                ),
//              ),
//              padding: EdgeInsets.symmetric(vertical: 10.0),
//            ),
//            onTap: (){
//              setState(() => _menuShown = !_menuShown);
//              _checkStockOutStatus();
//            },
//          ),
//          Container(height: 1.5, color: AppColors.colorF1F1F1,),
//          InkWell(
//            child: Padding(
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  Icon(Icons.edit, color: AppColors.colorBlue, size: 18.0,),
//                  Text(
//                    locale.txtInsertCodeManually,
//                    style: TextStyle(
//                        color: AppColors.colorBlueDark,
//                        fontWeight: FontWeight.w600,
//                        fontSize: 14.0
//                    ),
//                  )
//                ],
//              ),
//              padding: EdgeInsets.symmetric(vertical: 10.0,),
//            ),
//            onTap: (){
//              setState(() => _menuShown = !_menuShown);
//              _customJANCodeInput();
//            },
//          ),
//        ],
//      ),
//    );
//  }

  /// If user press on the back button, show the confirmation popup
  /// and return to order list on confirmation
  Future<bool> _onWillPop() async {
    if(loadingState == LoadingState.NO_DATA || loadingState == LoadingState.ERROR) {
      Navigator.of(context).pop();
      return false;
    }
    return await ConfirmationDialog(
      context,
      locale.txtReturnToOrderList,
      locale.msgReturnToOrderList,
      locale.txtReturnToTheList,
          () => Navigator.of(context).pop(),
    ).show() ?? false;
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
              AppIcons.icBackToList, size: 48.0, color: loadingState == LoadingState.NO_DATA || loadingState == LoadingState.ERROR? AppColors.colorBlue : Colors.white
          ),
          iconColor: Colors.white,
          background: Colors.transparent,
//          menu: InkWell(
//            child: AppIcons.loadIcon(AppIcons.icSettings, size: 48.0, color: Colors.white),
//            onTap: () => setState(() => _menuShown = !_menuShown),
//          ),
          menu: GestureDetector(
            onTapDown: (TapDownDetails details) {
              _showMenu(details.globalPosition);
            },
            child: AppIcons.loadIcon(AppIcons.icSettings, size: 48.0, color: Colors.white),
          ),
          onTapNavigation: () => _onWillPop(),
          error: _isUnderWork? '${_orderItem.lockedName}が作業中' : '',
        ),
        backgroundColor: AppColors.colorWhite,
        body: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: loadingState == LoadingState.NO_DATA || loadingState == LoadingState.ERROR? _isUnderWork? 100.0 : 74.0 : 0),
              child: _bodyBuilder(),
            ),
//            Visibility(
//                child: Positioned(
//                  child: ShapedWidget(
//                    child: _buildMenu(),
//                    background: AppColors.colorBlue,
//                  ),
//                  right: 13.0,
//                  top: _isUnderWork? 105.0 : 74.0,
//                ),
//              visible: _menuShown,
//            ),
          ],
        ),
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
      _checkJanCodeProduct(_qrText, false);
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
    if(!isOnline) {
      _showToast(locale.errorInternetIsNotAvailable);
      _refreshController.refreshCompleted();
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }

    String imei = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = imei;
    params[Params.ORDER_ID] = _orderItem.orderId;

    final response = await HttpUtil.get(HttpUtil.GET_PICKING_LIST, params: params);
    _refreshController.refreshCompleted();
    if (response.statusCode != HttpCode.OK) {
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap[Params.CODE];
    if(code == HttpCode.NOT_FOUND) {
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }
    final List data = responseMap[Params.DATA];
    List<ProductEntity> items = data.map(
            (data) => ProductEntity.fromJson(data)
    ).toList();
//    List<ProductEntity> items = ProductEntity.dummyProducts();

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
    if(_isPickingComplete()) _selectNextStep();
  }

  /// If user wants to use a fullscreen scanner this function provides that.
  /// A fullscreen function is popped up and this function waits for the
  /// scan result of the scanner. If the scanner finds a barcode
  /// this function calls '_checkJanCodeProduct' to check that code in server
  void _fullScreenScanner() async {
    _pauseCamera();
    final results = await Navigator.of(context).push(
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => ScannerScreen(
              navigationIcon: AppIcons.loadIcon(
                  AppIcons.icBackToList,
                  size: 48.0,
                  color: Colors.white
              ),
              menu: GestureDetector(
                onTapDown: (TapDownDetails details) {
                  _showMenu(details.globalPosition);
                },
                child: AppIcons.loadIcon(AppIcons.icSettings, size: 48.0, color: Colors.white),
              ),
//              menu: InkWell(
//                child: AppIcons.loadIcon(
//                    AppIcons.icSettings, size: 48.0, color: Colors.white
//                ),
//                onTap: () {
//                  Navigator.pop(context);
//
//                  setState(() => _menuShown = !_menuShown);
//                },
//              ),
            ),
            fullscreenDialog: true
        )
    );

    _resumeCamera();
    if (results != null && results.containsKey(Params.QR_CODE)) {
      setState(() {
        _qrText = results[Params.QR_CODE];
      });
      _checkJanCodeProduct(_qrText, false);
    }
  }

  /// This function checks the provided janCode in the server and if a valid
  /// product is found it calls '_getProductPickingCount' function to popup
  /// new product add dialog
  /// The result of the api check can be
  /// 1. No product found for the janCode
  /// 2. The product is already picked
  /// 3. New product
  _checkJanCodeProduct(janCode, bool manualInput) async {
    if(!isOnline) {
      _showToast(locale.errorInternetIsNotAvailable);
      _resumeCamera();
      return;
    }

    CommonWidget.showLoader(context, cancelable: true);
    String imei = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = imei;
    params[Params.ORDER_ID] = _orderItem.orderId;
    params[Params.JAN_CODE] = janCode;
    params[Params.FLAG] = manualInput? JANCodeScanFlag.MANUAL : JANCodeScanFlag.SCAN;

    final response = await HttpUtil.get(HttpUtil.CHECK_PICKED_ITEM, params: params);
    Navigator.of(context).pop();
    if (response.statusCode != HttpCode.OK) {
      _showToast(locale.errorServerIsNotAvailable,);
      _resumeCamera();
      return;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap[Params.CODE];
    final msg = responseMap[Params.MSG];
    if(code == PickingCheckStatus.PICKED) {
//      _showToast('読み取り済みのバーコードです。',);
      _showToast(msg);
      _resumeCamera();
      return;
    }
    if(code == PickingCheckStatus.NOT_AVAILABLE
        || code == PickingCheckStatus.NOT_AVAILABLE_IN_THE_ORDER) {
//      _showToast('注文の商品と異なる商品です。',);
      _showToast(msg);
      _resumeCamera();
      return;
    }
    final data = responseMap[Params.DATA];
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

    if(product == null) {
      _resumeCamera();
      return;
    }

    AddProductDialog(context, product, (int pickCount) {
      Navigator.of(context).pop();
      pickCount > 0? _updateProductPickingCount(product, pickCount)
          : _resumeCamera();
    }, onCancel: () => _resumeCamera()).show();
  }

  /// After 'AddProductDialog' this function is called to add the new product to
  /// the server. If successfully added to the server, do the following
  /// 1. If the picking count is less that itemCount add to the picking list
  /// 2. If equal, add to the picked list and remove from the picking list
  /// Finally, Update the state with the new data
  _updateProductPickingCount(ProductEntity product, int pickCount) async {
    if(!isOnline) {
      _showToast(locale.errorInternetIsNotAvailable);
      return;
    }

    String imei = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = imei;
    params[Params.ORDER_ID] = _orderItem.orderId;
    params[Params.JAN_CODE] = product.janCode;
    params[Params.PICKING_COUNT] = pickCount;

    final response = await HttpUtil.post(HttpUtil.UPDATE_PICKING_COUNT, params);
    if (response.statusCode != HttpCode.OK) {
      _showToast(locale.errorServerIsNotAvailable,);
      _resumeCamera();
      return;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap[Params.CODE];
//    final msg = responseMap[Params.MSG];
    if(code == PickingCheckStatus.OVER_REGISTRATION_QUANTITY) {
      _showToast('読み取り済みのバーコードです。',);
      _resumeCamera();
      _fetchData();
      return;
    }
    if(code != HttpCode.OK) {
      _showToast('読み取り済みのバーコードです。',);
      _resumeCamera();
      _fetchData();
      return;
    }
    if(_isPickingComplete()) await _completePicking();
    _resumeCamera();
    _fetchData();
  }

  /// After every picking action check if all items are picked
  /// If picked, popup to go to packing or select another odder
  _isPickingComplete() {
    return _scannedProducts.isEmpty && _scanCompletedProducts.isNotEmpty;
  }

  /// Select next step when all product's picking is complete.
  /// Total three options
  /// 1. Start packing -> Update picking status and ask for starting packing
  /// 2. Check missing order -> Check missing order
  /// 3. Start picking for another order -> Go back to order list screen
  _selectNextStep() async {
    _pauseCamera();
    SelectNextStepDialog(
        context: context,
        onConfirm: () => _confirmPacking(),
        onReportMissing: () => _checkStockOutStatus(fromNextStepDialog: true),
        onOther: () => Navigator.of(context).pop({
          Params.ORDER_ID: _orderItem.orderId,
          Params.STATUS: TransitStatus.PICKING_DONE,
        }),
    ).show();
  }

  _completePicking() async {
    if(!isOnline) {
      _showToast(locale.errorInternetIsNotAvailable);
      return;
    }
    CommonWidget.showLoader(context, cancelable: true);
    String imei = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = imei;
    params[Params.ORDER_ID] = _orderItem.orderId;
    params[Params.STATUS] = PickingStatus.DONE;

    var response = await HttpUtil.post(HttpUtil.UPDATE_PICKING_STATUS, params);
    Navigator.of(context).pop();
    if (response.statusCode != HttpCode.OK) {
      ToastUtil.show(context, locale.errorServerIsNotAvailable,);
      return;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap[Params.CODE];
    if(code != HttpCode.OK) {
      _showToast('ピッキングStatusは更新する事ができません。',);
      return;
    }
  }

  /// This function uses 'UPDATE_PICKING_STATUS' api to update the picking
  /// status as done and show the confirmation dialog to start packing
  _confirmPacking() async {
    ConfirmationDialog(
        context,
        locale.txtStartShippingPreparation,
        locale.msgStartPicking,
        locale.txtStart, () => _startPackingForResult(),
      cancelable: false,
      onCancel: () => _selectNextStep()
    ).show();
  }

  /// Start packing when all items are picked.
  /// First change the packing status of the order as working
  /// Then Go to the packing screen and wait for the result
  _startPackingForResult() async {
    if(!isOnline) {
      _showToast(locale.errorInternetIsNotAvailable);
      return;
    }

    CommonWidget.showLoader(context, cancelable: true);
    String imei = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = imei;
    params[Params.ORDER_ID] = _orderItem.orderId;
    params[Params.STATUS] = PackingStatus.WORKING;
    var response = await HttpUtil.post(HttpUtil.UPDATE_PACKING_STATUS, params);
    Navigator.of(context).pop();
    if (response.statusCode != HttpCode.OK) {
      ToastUtil.show(context, locale.errorServerIsNotAvailable,);
      return;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap[Params.CODE];
    if(code != HttpCode.OK) {
      _showToast('パッキングStatusは更新する事ができません。',);
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

    Navigator.of(context).pop(results);
  }

  /// Dispose the controller when the screen is disposed
  @override
  void dispose() {
    _refreshController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  _showToast(
      String msg, {
        error = true,
        fromTop = true,
  }) {
    final icon = AppIcons.loadIcon(
      error? AppIcons.icError : AppIcons.icLike, color: Colors.white, size: 16.0
    );
    ToastUtil.show(
        context, msg,
        icon: icon,
        fromTop: fromTop, verticalMargin: 150, error: error
    );
  }
}