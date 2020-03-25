import 'package:flutter/material.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/dialog/details_dialog.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';

class PackingProductItem extends StatelessWidget {
  final ProductEntity product;
  final Function onPressed;

  PackingProductItem({
    Key key,
    @required this.product,
    this.onPressed,
  }) : super(key: key);

  ListTile _listTileBuilder(context) {
    O2OLocalizations locale = O2OLocalizations.of(context);

    return ListTile(
      leading: AppImages.loadImage(product.imageUrl, isAsset: false),
      title: Text(
        product.title,
        style: TextStyle(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              '${locale.txtJanCode}: ${product.janCode}',
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
          Row(
            children: <Widget>[
              RichText(
                text: TextSpan(
                  text: 'EC 価格 (${locale.txtTaxIncluded})  ',
                  style: TextStyle(
                      color: Colors.black54, fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: '¥${product.price}',
                      style: TextStyle(
                          color: AppColors.colorRed,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Container(
                height: 24,
                width: 48,
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 230, 242, 255),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Text(
                  'x ${product.itemCount}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      isThreeLine: true,
      contentPadding: EdgeInsets.all(10),
      onTap: () {
        DetailsDialog(
          context,
          product.title,
          '${locale.txtJanCode}: ${product.janCode}',
          product.imageUrl,
        ).show();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: _listTileBuilder(context),
    );
  }
}
