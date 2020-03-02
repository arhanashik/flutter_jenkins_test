import 'package:flutter/material.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/ui/widget/progressbar/circular_progress_bar.dart';
import 'package:o2o/ui/widget/dialog/details_dialog.dart';
import 'package:o2o/util/localization/o2o_localizations.dart';

class ScannedProductItem extends StatelessWidget {
  final ProductEntity scannedProduct;
  final Function onPressed;

  ScannedProductItem({
    Key key,
    @required this.scannedProduct,
    this.onPressed,
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

  ListTile _listTileBuilder(context) {
    O2OLocalizations locale = O2OLocalizations.of(context);

    final imageUrl = scannedProduct.imageUrl.isEmpty
        ? AppConst.NO_IMAGE_URL : scannedProduct.imageUrl;

    return ListTile(
      leading: GestureDetector(
        child: Image.network(imageUrl, fit: BoxFit.fill,),
        onTap: () => _showProductDetails(context),
      ),
      title: Text(
        scannedProduct.title,
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text(
          '${locale.txtJanCode}: ${scannedProduct.janCode}'
              '\n${locale.txtCategoryName}: ${scannedProduct.category}',
          style: TextStyle(color: Colors.black, fontSize: 14),
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
    return InkWell(
      child: _listTileBuilder(context),
    );
  }
}
