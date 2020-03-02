import 'package:flutter/material.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/packing_product_item.dart';
import 'package:o2o/ui/widget/button/simple_button.dart';

class Step1Screen extends StatefulWidget {

  Step1Screen(this.orderItem, this.scannedProducts, this.onNextScreen);
  final OrderItem orderItem;
  final List scannedProducts;
  final Function onNextScreen;

  @override
  _Step1ScreenState createState() => _Step1ScreenState(orderItem, scannedProducts, onNextScreen);
}

class _Step1ScreenState extends BaseState<Step1Screen> {

  _Step1ScreenState(this.orderItem, this.scannedProducts, this.onNextScreen);
  final OrderItem orderItem;
  final List scannedProducts;
  final Function onNextScreen;

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

  Widget _buildList() {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: scannedProducts.length + 2,
      itemBuilder: (BuildContext context, int index) {

        if (index == scannedProducts.length) {
          return Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GradientButton(
                  text: locale.txtGoToReceiptNumberInsertion,
                  onPressed: () => onNextScreen(),
                  showIcon: true,
                )
              ],
            ),
          );
        }

        if (index == scannedProducts.length + 1) {
          return CommonWidget.buildProgressIndicator(loadingState);
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: PackingProductItem(product: scannedProducts[index],),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(thickness: 2.0,);
      },
    );
  }

  _buildFooter() {

    int totalPrice = 0;
    int itemCount = 0;
    scannedProducts.forEach((scannedProduct) {
      if(scannedProduct is ProductEntity) {
        totalPrice += scannedProduct.price * scannedProduct.pickedItemCount;
        itemCount += scannedProduct.pickedItemCount;
      }
    });

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
                  '13:00',
                  style: TextStyle(
                    color: AppColors.colorBlueDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
//          Container(
//            height: 80,
//            decoration: BoxDecoration(
//              color: Colors.white,
//              borderRadius: BorderRadius.all(Radius.circular(5))
//            ),
//            padding: EdgeInsets.symmetric(horizontal: 10),
//            child: Column(
//              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                RichText(
//                    text: TextSpan(
//                      style: TextStyle(
//                        color: Colors.black,
//                        fontSize: 14,
//                        fontWeight: FontWeight.bold,
//                      ),
//                      children: [
//                        TextSpan(
//                            text: locale.txtShippingPlan
//                        ),
//                        TextSpan(
//                            text: '    13:00',
//                          style: TextStyle(color: Colors.lightBlue, fontSize: 16),
//                        ),
//                      ],
//                    ),
//                ),
//                Container(
//                  width: 160,
//                  height: 1,
//                  color: Colors.black12,
//                  margin: EdgeInsets.symmetric(vertical: 5),
//                ),
//                RichText(
//                  text: TextSpan(
//                    style: TextStyle(
//                        color: Colors.black,
//                        fontSize: 14,
//                    ),
//                    children: [
//                      TextSpan(
//                          text: locale.txtOrderNumber,
//                        style: TextStyle(fontWeight: FontWeight.bold),
//                      ),
//                      TextSpan(
//                        text: '    ${orderItem.orderNo}',
//                        style: TextStyle(fontSize: 12),
//                      ),
//                    ],
//                  ),
//                ),
//              ],
//            ),
//          ),
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
                  '¥$totalPrice',
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