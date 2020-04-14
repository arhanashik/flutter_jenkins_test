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

  _buildLeading(BuildContext context, O2OLocalizations locale, ProductEntity product) {
    return InkWell(
      child: AppImages.loadSizedImage(
          product.imageUrl, isAsset: false, width: 48.0, height: 48.0
      ),
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

  _buildPriceView(O2OLocalizations locale, int price) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 8,),
          child: Text(
            'EC 価格 (${locale.txtTaxIncluded})',
            style: TextStyle(
                color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold
            ),
          ),
        ),
        Text(
          '¥$price',
          style: TextStyle(
              color: AppColors.colorAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold
          ),
        )
      ],
    );
  }

  _buildItemCountView(int itemCount) {
    return Container(
      height: 22,
      width: 48,
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0x11FF6591),
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.clear, color: Colors.black, size: 12,),
          ),
          Text(
            '$itemCount',
            style: TextStyle(
              color: AppColors.colorAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  ListTile _listTileBuilder(context) {
    O2OLocalizations locale = O2OLocalizations.of(context);

    final janCode = product.janCode == null? '' : product.janCode.toString();

    return ListTile(
      leading: _buildLeading(context, locale, product),
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
          child: _buildJanCodeView(locale, janCode),
          ),
          Row(
            children: <Widget>[
              _buildPriceView(locale, product.price),
              Spacer(),
              _buildItemCountView(product.itemCount),
            ],
          )
        ],
      ),
      isThreeLine: true,
      contentPadding: EdgeInsets.symmetric(vertical: 6),
      onTap: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: _listTileBuilder(context),
    );
  }
}
