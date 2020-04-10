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
  );
  final OrderItem orderItem;
  final Function onNextScreen;

  @override
  _Step1ScreenState createState() => _Step1ScreenState(
    orderItem, onNextScreen,
  );
}

class _Step1ScreenState extends BaseState<Step1Screen> {

  _Step1ScreenState(
      this._orderItem,
      this._onNextScreen,
  );
  final OrderItem _orderItem;
  final Function _onNextScreen;

  PackingList _packingList = PackingList();
  final _refreshController = RefreshController(initialRefresh: true);

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

  _buildList() {
    final itemCount = _packingList.products == null? 0 : _packingList.products.length;
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: itemCount == 0? 0 : itemCount + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == itemCount) {
          return Padding(
            padding: EdgeInsets.only(bottom: itemCount > 1? 90 : 10),
            child: itemCount > 0? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GradientButton(
                  text: locale.txtGoToReceiptNumberInsertion,
                  onPressed: () => _onNextScreen(_packingList),
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
        return Divider(thickness: 2.0,);
      },
    );
  }

  _buildFooter() {
    int itemCount = 0;
    _packingList.products?.forEach((scannedProduct) {
      if(scannedProduct is ProductEntity) {
        itemCount += scannedProduct.itemCount;
      }
    });

    final deliveryDate = Common.convertToDateTime(
        _packingList.appointedDeliveringTime
    );
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.blueGradient),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  locale.txtShippingPlanTime,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Container(
                width: 100,
                height: 36,
                margin: EdgeInsets.only(top: 4,),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Text(
                  '${deliveryDate.hour}:${deliveryDate.minute}',
                  style: TextStyle(
                    color: AppColors.colorBlueDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: RichText(
                  text: TextSpan(
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      children: [
                        TextSpan(text: locale.txtTotalAmountOfMoney,),
                        TextSpan(
                          text: '  (${locale.txtTaxIncluded})',
                          style: TextStyle(fontSize: 12),
                        )
                      ]
                  ),
                ),
              ),
              Container(
                width: 100,
                height: 36,
                margin: EdgeInsets.only(top: 4,),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 16,),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Text(
                  '¥${_packingList.totalPrice}',
                  style: TextStyle(
                      color: AppColors.colorRed,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),
                ),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  locale.txtTotalProductCount,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Container(
                width: 100,
                height: 36,
                margin: EdgeInsets.only(top: 4,),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 16,),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Text(
                  '$itemCount点',
                  style: TextStyle(
                    color: AppColors.colorRed,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
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
      margin: EdgeInsets.only(top: 8),
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionTitleBuilder(locale.txtProductList),
          Padding(padding: EdgeInsets.only(top: 10),),
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