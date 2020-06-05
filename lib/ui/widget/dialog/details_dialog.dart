import 'package:flutter/material.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';

class DetailsDialog {
  final BuildContext context;
  final ProductEntity product;

  DetailsDialog(this.context, this.product,);

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

  show() {
    O2OLocalizations locale = O2OLocalizations.of(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: CommonWidget.roundRectBorder(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: <Widget>[
                    Spacer(),
                    IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop())
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AppImages.loadSizedImage(
                      product.imageUrl,
                      width: MediaQuery.of(context).size.width - 130,
                      height: MediaQuery.of(context).size.width - 130,
                      isAsset: false,
                      placeholder: AppImages.NO_IMAGE_URL_LARGE,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5.0),
                  child: Text(
                    product.title,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24,),
                  child: _buildJanCodeView(locale, product.janCode.toString()),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 24, top: 5, right: 24, bottom: 24),
                  child: Text(
                    '${locale.txtCategoryName}: ${product.category}',
                    style: TextStyle(color: Colors.black, fontSize: 12,),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
