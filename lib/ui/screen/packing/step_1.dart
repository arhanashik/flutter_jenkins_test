import 'package:flutter/material.dart';
import 'package:o2o/data/product/packing_list.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/packing_product_item.dart';
import 'package:o2o/util/helper/common.dart';

class Step1Screen extends StatefulWidget {

  Step1Screen(this.packingList, this.onNextScreen);
  final PackingList packingList;
  final Function onNextScreen;

  @override
  _Step1ScreenState createState() => _Step1ScreenState(
      packingList, onNextScreen
  );
}

class _Step1ScreenState extends BaseState<Step1Screen> {

  _Step1ScreenState(
      this._packingList,
      this._onNextScreen
  );
  final PackingList _packingList;
  final Function _onNextScreen;

  Container _sectionTitleBuilder(title) {
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
    final itemCount = _packingList.products.length;
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: itemCount + 2,
      itemBuilder: (BuildContext context, int index) {
        if (index == itemCount) {
          return Padding(
            padding: EdgeInsets.only(bottom: 40),
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

        if (index == itemCount + 1) {
          return CommonWidget.buildProgressIndicator(loadingState);
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
    _packingList.products.forEach((scannedProduct) {
      if(scannedProduct is ProductEntity) {
        itemCount += scannedProduct.itemCount;
      }
    });

    final deliveryDate = Common.convertToDateTime(
        _packingList.appointedDeliveringTime
    );
    return Container(
      height: 100,
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
                _buildList(),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

}