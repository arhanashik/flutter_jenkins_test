import 'package:flutter/material.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';

class AddProductDialog {

  AddProductDialog(this.context, this.product, this.onInsertAndNext) {
    pickCount = product.pickedItemCount;
  }
  final BuildContext context;
  final ProductEntity product;
  final Function onInsertAndNext;
  int pickCount;

  _loadImg(String url, double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: AppImages.loadSizedImage(url, height: 80.0, width: 80.0, isAsset: false),
    );
  }

  _buildCounter(StateSetter setDialogState) {
    return Row(
      children: <Widget>[
        GestureDetector(
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.blueGradient),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                )
            ),
            child: Icon(Icons.remove, color: Colors.white,),
            alignment: Alignment.center,
          ),
          onTap: () {
            if(pickCount > 0) {
              setDialogState(() => pickCount--);
            }
          },
        ),
        Container(
          height: 32,
          width: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.colorBlue),
                bottom: BorderSide(color: AppColors.colorBlue),
              )
          ),
          child: Text(
            pickCount.toString(),
            style: TextStyle(
              fontSize: 20,
              color: AppColors.colorBlueDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GestureDetector(
          child: Container(
            height: 32,
            width: 32,decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.blueGradient),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              )
          ),
            child: Icon(Icons.add, color: Colors.white,),
            alignment: Alignment.center,
          ),
          onTap: () {
            if(pickCount < product.itemCount) {
              setDialogState(() => pickCount++);
            }
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10,),
          child: Text(
            '/',
            style: TextStyle(
              fontSize: 32,
              color: AppColors.colorBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          product.itemCount.toString(),
          style: TextStyle(
            fontSize: 24,
            color: AppColors.colorBlueDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

   _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        GradientButton(
          text: O2OLocalizations.of(context).txtCancel,
          txtColor: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
          gradient: AppColors.btnGradientLight,
        ),
        GradientButton(
          text: O2OLocalizations.of(context).txtSubmitAndNext,
          onPressed: () => onInsertAndNext(pickCount - product.pickedItemCount),
          showIcon: true,
        ),
      ],
    );
  }

  show() {
    O2OLocalizations locale = O2OLocalizations.of(context);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(shape: CommonWidget.roundRectBorder(5.0), child: Container(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CommonWidget.buildDialogHeader(
                        context, O2OLocalizations.of(context).txtProductScanned
                    ),
                    Row(
                      children: <Widget>[
                        _loadImg(product.imageUrl, 10.0),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                                child: Text(
                                  product.title,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 10, right: 10),
                                child: Text(
                                  '${locale.txtJanCode}: ${product.janCode}'
                                      '\n${locale.txtCategoryName}: ${product.category}',
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                              ),
                              _buildCounter(setDialogState),
                            ],
                          ),
                        )
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: 16)),
                    _buildActionButtons(),
                    Padding(padding: EdgeInsets.only(bottom: 10)),
                  ],
                );
              },
            ),
          ));
        });
  }
}