import 'package:flutter/material.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/checkable_product_item.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/common/topbar.dart';

class FullScreenMissingInformationCheckerDialog extends StatefulWidget {
  FullScreenMissingInformationCheckerDialog({this.items});

  final List items;

  @override
  FullScreenMissingInformationCheckerDialogState createState() =>
      new FullScreenMissingInformationCheckerDialogState(items);
}

class FullScreenMissingInformationCheckerDialogState extends BaseState<FullScreenMissingInformationCheckerDialog> {

  FullScreenMissingInformationCheckerDialogState(this._items);

  List _items = List();
  List _resultList = List();
  bool confirmation = false;

  _sectionTitleBuilder(title) {
    return Container(
      margin: EdgeInsets.only(left: 16, top: 16, bottom: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 3.0,
            height: 24.0,
            decoration: BoxDecoration(
              color: AppColors.colorBlue,
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              title, style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black
            ),
            ),
          )
        ],
      ),
    );
  }

  _buildMessage() {
    return Container(
      padding: EdgeInsets.all(confirmation? 13 : 10),
      decoration: confirmation? BoxDecoration(color: AppColors.colorF1F1F1) : BoxDecoration(
        gradient: LinearGradient(colors: AppColors.blueGradient),
      ),
      alignment: Alignment.center,
      child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(confirmation? 8 : 0),
          decoration: confirmation? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ) : null,
          child: confirmation? RichText(
            textAlign: TextAlign.center,
            text: TextSpan (
              style: TextStyle(color: Colors.black, height: 1.4),
              children: [
                CommonWidget.textSpanBuilder('以下の商品の欠品を報告します。',),
                CommonWidget.textSpanBuilder(
                    '\n欠品が報告されと、欠品商品を含む\n注文自体がキャンセルとなります。',
                  fontSize: 14.0, bold: true, color: AppColors.colorAccent,
                ),
                CommonWidget.textSpanBuilder('\n本当によろしですか？',),
              ],
            ),
          ) : Text(
            locale.txtSelectProductToCheckMissingInfo,
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
          )
      )
    );
  }

  _buildList() {
    return ListView.builder(
        itemCount: confirmation? _resultList.length : _items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = confirmation? _resultList[index] : _items[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: CheckableProductItem(
              scannedProduct: item,
              checkboxVisible: !confirmation,
              isChecked: _resultList.contains(item),
              onChecked: (checked) => _onItemChecked(checked, item),
            ),
          );
        }
    );
  }

  _buildActionButtons() {
    return Container(
      height: 40,
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Visibility(
            child: GradientButton(
              text: locale.txtReturn,
              txtColor: Colors.black,
              onPressed: () => setState(() => confirmation = false),
              gradient: AppColors.disabledGradient,
              padding: EdgeInsets.symmetric(horizontal: 20.0,),
              enabled: _resultList.isNotEmpty,
              showIcon: true,
              icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 14.0,),
            ),
            visible: confirmation,
          ),
          GradientButton(
            text: locale.txtReportStorage,
            onPressed: () => _confirmBefore(),
            enabled: _resultList.isNotEmpty,
            showIcon: true,
            padding: EdgeInsets.symmetric(horizontal: 25.0,),
          ),
        ],
      ),
    );
  }

  _buildBody() {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildMessage(),
            _sectionTitleBuilder(locale.txtProductList),
            Expanded(child: _buildList(),),
          ],
        ),
        _buildActionButtons(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: TopBar(
        title: confirmation? locale.txtConfirmMissingInfo : '',
        navigationIcon: Container(),
        menu: InkWell(
          child: AppIcons.loadIcon(
              AppIcons.icClose, size: 48.0, color: AppColors.colorBlue
          ),
          onTap: () => Navigator.of(context).pop(null),
        ),
      ),
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  void _onItemChecked(bool checked, item) {
    setState(() {
      checked? _resultList.add(item) : _resultList.remove(item);
    });
  }

  _confirmBefore() {
    if(confirmation) {
      setState(() {
        _resultList.forEach((_item) => _items.remove(_item));
      });
      Navigator.of(context).pop(_resultList);
      _resultList.clear();
      return;
    }

    setState(() => confirmation = true);
  }
}