import 'package:flutter/material.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/dialog/details_dialog.dart';
import 'package:o2o/ui/widget/progressbar/circular_progress_bar.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';

class ScannedProductItem extends StatelessWidget {
  final ProductEntity scannedProduct;
  final Function onPressed;
  final Function onChangeQuantity;

  ScannedProductItem({
    Key key,
    @required this.scannedProduct,
    this.onPressed,
    this.onChangeQuantity
  }) : super(key: key);

  _buildJanCodeView(O2OLocalizations locale, String janCode) {
    final janCodeLeading = (janCode.length < 3)
        ? janCode : janCode.substring(0, janCode.length - 3);
    final janCodeTail = (janCode.length < 3)
        ? '' : janCode.substring(janCode.length - 3);

    return RichText(
      text: TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 12),
          children: [
            TextSpan(text: '${locale.txtJanCode}: $janCodeLeading'),
            TextSpan(
                text: janCodeTail,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold
                )
            )
          ]
      ),
    );
  }

  _showProductDetails(BuildContext context) {
    O2OLocalizations locale = O2OLocalizations.of(context);
    DetailsDialog(context, scannedProduct,).show();
  }

  _buildLeading(BuildContext context, String imageUrl) {
    return GestureDetector(
      child: AppImages.loadImage(imageUrl, isAsset: false,),
      onTap: () => _showProductDetails(context),
    );
  }

  _buildContent(BuildContext context, ProductEntity product) {
    O2OLocalizations locale = O2OLocalizations.of(context);

    return Container(
      padding: EdgeInsets.only(left: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            product.title,
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: _buildJanCodeView(locale, product.janCode.toString()),
          ),
          Text(
            '${locale.txtCategoryName}: ${product.category}',
            style: TextStyle(color: Colors.black, fontSize: 12,),
          ),
          product.pickedItemCount < product.itemCount? Container(
            height: 28.0,
            width: 100.0,
            margin: EdgeInsets.only(top: 5.0),
            child: GradientButton(
              text: '数量変更',
              fontSize: 12.0,
              onPressed: () => onChangeQuantity(),
              showIcon: true,
              icon: Icon(Icons.edit, color: Colors.white, size: 16.0,),
              borderRadius: 16.0,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
            ),
          ) : Container(),
        ],
      ),
    );
  }

  _buildTrailing(ProductEntity product) {
    return Container(
      height: 48,
      width: 48,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressBar(
              progress: product.pickedItemCount.toDouble() /
                  product.itemCount.toDouble(),
              progressColor: Colors.lightBlue,
              backgroundColor: Color(0xFFB3E5FC),
              strokeWidth: 3.0,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                product.pickedItemCount.toString(),
                style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(color: Colors.grey, height: 1, width: 24,),
              Text(
                product.itemCount.toString(),
                style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  _bodyBuilder(BuildContext context, ProductEntity product) {
    return InkWell(
      onTap: () => onPressed == null? _showProductDetails(context) : onPressed(),
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey,),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: _buildLeading(context, product.imageUrl),
            ),
            Expanded(
              flex: 6,
              child: _buildContent(context, scannedProduct),
            ),
            Expanded(
              flex: 2,
              child: _buildTrailing(scannedProduct),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _bodyBuilder(context, scannedProduct);
  }
}
