import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';

import 'dialog/details_dialog.dart';

class CheckableProductItem extends StatelessWidget {
  final ProductEntity scannedProduct;
  final bool checkboxVisible;
  final bool isChecked;
  final Function onChecked;

  CheckableProductItem({
    Key key,
    @required this.scannedProduct,
    this.checkboxVisible = true,
    @required this.isChecked,
    this.onChecked,
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
    DetailsDialog(
      context,
      scannedProduct.title,
      '${locale.txtJanCode}: ${scannedProduct.janCode}',
      scannedProduct.imageUrl,
    ).show();
  }

  _buildLeading(BuildContext context, String imageUrl) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Visibility(
          child: Checkbox(
            value: isChecked,
            onChanged: (checked) => onChecked(checked),
          ),
          visible: checkboxVisible,
        ),
        GestureDetector(
          child: AppImages.loadSizedImage(
            imageUrl, isAsset: false, width: 56.0, height: 56.0
          ),
          onTap: () => _showProductDetails(context),
        )
      ],
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
        ],
      ),
    );
  }

  _bodyBuilder(BuildContext context, ProductEntity product) {
    return Container(
      padding: EdgeInsets.only(
      left: checkboxVisible? 0 : 13, top: 10, right: 13, bottom: 10
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: checkboxVisible && isChecked? AppColors.colorBlue : Colors.black12,
          width: 1.5,
        ),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildLeading(context, product.imageUrl),
          Expanded(
            child: _buildContent(context, scannedProduct),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _bodyBuilder(context, scannedProduct);
  }
}
