import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';

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

  ListTile _listTileBuilder(context) {
    O2OLocalizations locale = O2OLocalizations.of(context);

    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Visibility(
            child: Checkbox(
              value: isChecked,
              onChanged: (checked) => onChecked(checked),
            ),
            visible: checkboxVisible,
          ),
          AppImages.loadImage(scannedProduct.imageUrl, isAsset: false),
        ],
      ),
      title: Text(
        scannedProduct.title,
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 5),
        child: Text(
          '${locale.txtJanCode}: ${scannedProduct.janCode}',
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: checkboxVisible? 5 : 16),
      onTap: () => onChecked(!isChecked),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: _listTileBuilder(context),
    );
  }
}
