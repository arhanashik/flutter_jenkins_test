import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/product/packing_list.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/packing_product_item.dart';
import 'package:o2o/ui/widget/toast/toast_util.dart';
import 'package:o2o/util/helper/common.dart';
import 'package:o2o/util/lib/remote/http_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Step1Screen extends StatefulWidget {

  Step1Screen(
      this.orderItem,
      this.onNextScreen,
      this.onLoadData,
  );
  final OrderItem orderItem;
  final Function onNextScreen;
  final Function onLoadData;

  @override
  _Step1ScreenState createState() => _Step1ScreenState(
    orderItem, onNextScreen, onLoadData
  );
}

class _Step1ScreenState extends BaseState<Step1Screen> {

  _Step1ScreenState(
      this._orderItem,
      this._onNextScreen,
      this._onLoadData,
  );
  final OrderItem _orderItem;
  final Function _onNextScreen;
  final Function _onLoadData;

  PackingList _packingList = PackingList();
  final _refreshController = RefreshController(initialRefresh: true);

  _sectionTitleBuilder(title) {
    return Container(
      margin: EdgeInsets.only(left: 16, top: 10),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(width: 3.0, color: Colors.lightBlue)),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 10),
        child: Text(
          title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  _buildList() {
    final itemCount = _packingList.products == null? 0 : _packingList.products.length;
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: itemCount == 0? 0 : itemCount + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == itemCount) {
          return Padding(
            padding: EdgeInsets.only(top: 14, bottom: 90),
            child: itemCount > 0? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GradientButton(
                  text: locale.txtGoToReceiptNumberInsertion,
                  onPressed: () => _onNextScreen(),
                  showIcon: true,
                )
              ],
            ) : Container(),
          );
        }
        final item = _packingList.products[index];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: PackingProductItem(product: item),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return CommonWidget.divider(
          height: 1.2,
          margin: EdgeInsets.symmetric(horizontal: 16,),
        );
      },
    );
  }

  _buildFooterItem(List<InlineSpan> titleSpans, String valueText, {
    Color fontColor = AppColors.colorAccent,
    double fontSize = 14.0,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 2,),
          child: RichText(
            text: TextSpan(
                style: TextStyle(color: Colors.white, fontSize: 12),
                children: titleSpans,
            ),
          ),
        ),
        Container(
          width: 100,
          height: 36,
          margin: EdgeInsets.only(top: 2,),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(3))
          ),
          child: Text(
            valueText,
            style: TextStyle(
              color: fontColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  _buildFooter() {
    if(_packingList.products == null) return Container();
    int itemCount = 0;
    _packingList.products.forEach((scannedProduct) {
      if(scannedProduct is ProductEntity) {
        itemCount += scannedProduct.itemCount;
      }
    });

    final deliveryDate = Common.convertToDateTime(
        _packingList.appointedDeliveringTime
    );
    return Container(
      height: 75,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.blueGradient),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildFooterItem(
              [TextSpan(text: locale.txtShippingPlanTime,),],
              '${deliveryDate.hour}:${deliveryDate.minute}',
              fontColor: AppColors.colorBlueDark
          ),
          _buildFooterItem(
              [
                TextSpan(text: locale.txtTotalAmountOfMoney,),
                TextSpan(
                  text: '  (${locale.txtTaxIncluded})',
                  style: TextStyle(fontSize: 10),
                )
              ],
            Common.formatPrice(_packingList.totalPrice),
            fontSize: _packingList.totalPrice.toString().length > 6? 10 : 14
          ),
          _buildFooterItem(
            [TextSpan(text: locale.txtTotalProductCount,),],
            '$itemCount点',
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    //_fetchData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: Colors.white,
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16,),
            child: CommonWidget.sectionTitleBuilder(locale.txtProductList),
          ),
          CommonWidget.divider(
            height: 1.2,
            margin: EdgeInsets.only(left: 16, top: 5, right: 16,),
          ),
          Flexible(
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height,),
                SmartRefresher(
                  enablePullDown: true,
                  header: ClassicHeader(
                    idleText: locale.txtPullToRefresh,
                    refreshingText: locale.txtRefreshing,
                    completeText: locale.txtRefreshCompleted,
                    releaseText: locale.txtReleaseToRefresh,
                  ),
                  child: _buildList(),
                  controller: _refreshController,
                  onRefresh: () => _fetchData(),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _fetchData() async {
    //setState(() => loadingState = LoadingState.LOADING);

    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final params = HashMap();
    params['imei'] = imei;
    params['orderId'] = _orderItem.orderId;
    final response = await HttpUtil.get(HttpUtil.GET_PACKING_LIST, params: params);
    _refreshController.refreshCompleted();
    final data = _validateResponse(response, 'Dataは取得する事ができません');
    if(data == null) {
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }
    final item = PackingList.fromJson(data);
    _onLoadData(item);
    //final PackingList item = PackingList.dummyPackingList();

    setState(() {
      if(item != null) {
        _packingList = item;
        loadingState = LoadingState.OK;
      }
    });
  }

  _validateResponse(response, String errorMsg) {
    if (response.statusCode != 200) {
      ToastUtil.show(
          context, locale.errorServerIsNotAvailable,
          icon: Icon(Icons.error, color: Colors.white,), error: true
      );
      return null;
    }

    final responseMap = json.decode(response.body);
    final code = responseMap['code'];
    if(code != HttpCode.OK) {
      ToastUtil.show(context, errorMsg);
      return null;
    }

    return responseMap['data'];
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}