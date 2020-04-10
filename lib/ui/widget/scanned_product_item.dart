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

  _showProductDetails(BuildContext context) {
    O2OLocalizations locale = O2OLocalizations.of(context);
    DetailsDialog(
      context,
      scannedProduct.title,
      '${locale.txtJanCode}: ${scannedProduct.janCode}',
      scannedProduct.imageUrl,
    ).show();
  }

  _listTileBuilder(context) {
    O2OLocalizations locale = O2OLocalizations.of(context);

    return ListTile(
      leading: GestureDetector(
        child: AppImages.loadImage(scannedProduct.imageUrl, isAsset: false),
        onTap: () => _showProductDetails(context),
      ),
      title: Text(
        scannedProduct.title,
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${locale.txtJanCode}: ${scannedProduct.janCode}'
                  '\n${locale.txtCategoryName}: ${scannedProduct.category}',
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            scannedProduct.pickedItemCount < scannedProduct.itemCount? Container(
              height: 28.0,
              width: 100.0,
              child: GradientButton(
                text: '数量変更',
                fontSize: 12.0,
                onPressed: () => onChangeQuantity(),
                showIcon: true,
                icon: Icon(Icons.edit, color: Colors.white, size: 16.0,),
                borderRadius: 16.0,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
              ),
            ) : Container()
          ],
        ),
      ),
      trailing: Container(
        height: 48,
        width: 48,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressBar(
                progress: scannedProduct.pickedItemCount.toDouble() /
                    scannedProduct.itemCount.toDouble(),
                progressColor: Colors.lightBlue,
                backgroundColor: Color(0xFFB3E5FC),
                strokeWidth: 3.0,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  scannedProduct.pickedItemCount.toString(),
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(color: Colors.grey, height: 1, width: 24,),
                Text(
                  scannedProduct.itemCount.toString(),
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      isThreeLine: true,
      contentPadding: EdgeInsets.all(10),
      onTap: () => onPressed == null? _showProductDetails(context) : onPressed(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _listTileBuilder(context);
  }
}
