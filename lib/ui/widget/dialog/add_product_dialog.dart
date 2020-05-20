import 'package:flutter/material.dart';
import 'package:o2o/data/product/product_entity.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';

class AddProductDialog {

  AddProductDialog(this.context, this.product, this.onInsertAndNext, {
    this.onCancel
  }) {
    pickCount = product.pickedItemCount;
    if(pickCount == 0) pickCount = 1;
  }
  final BuildContext context;
  final ProductEntity product;
  final Function onInsertAndNext;
  Function onCancel;
  int pickCount;

  _loadImg(String url,) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: AppImages.loadSizedImage(url, height: 64.0, width: 64.0, isAsset: false),
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

   _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        GradientButton(
          text: O2OLocalizations.of(context).txtCancel,
          txtColor: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
            if(onCancel != null) onCancel();
          },
          gradient: AppColors.btnGradientLight,
        ),
        GradientButton(
          text: O2OLocalizations.of(context).txtSubmitAndNext,
          onPressed: () => onInsertAndNext(pickCount - product.pickedItemCount),
          showIcon: true,
          enabled: pickCount > 0,
        ),
      ],
    );
  }

  show() {
    O2OLocalizations locale = O2OLocalizations.of(context);

    showDialog(
        context: context,
        barrierDismissible: false,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _loadImg(product.imageUrl,),
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
                              _buildJanCodeView(locale, product.janCode.toString()),
                              Padding(
                                padding: EdgeInsets.only(bottom: 10, right: 10),
                                child: Text(
                                  '${locale.txtCategoryName}: ${product.category}',
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