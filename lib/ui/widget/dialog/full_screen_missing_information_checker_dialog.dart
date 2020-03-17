import 'package:flutter/material.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/checkable_product_item.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';

class FullScreenMissingInformationCheckerDialog extends StatefulWidget {
  FullScreenMissingInformationCheckerDialog({this.items});

  final List items;

  @override
  FullScreenMissingInformationCheckerDialogState createState() => new FullScreenMissingInformationCheckerDialogState(items);
}

class FullScreenMissingInformationCheckerDialogState extends BaseState<FullScreenMissingInformationCheckerDialog> {

  FullScreenMissingInformationCheckerDialogState(this._items);

  List _items = List();
  List _resultList = List();
  bool confirmation = false;

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

  _buildBody() {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16, top: 16),
              child: Text(
                  locale.txtProductList,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: confirmation? _resultList.length : _items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = confirmation? _resultList[index] : _items[index];
                    return CheckableProductItem(
                      scannedProduct: item,
                      checkboxVisible: !confirmation,
                      isChecked: _resultList.contains(item),
                      onChecked: (checked) => _onItemChecked(checked, item),
                    );
                  }
              ),
            ),
          ],
        ),
        Container(
          height: 40,
          margin: EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Visibility(
                child: GradientButton(
                  text: locale.txtReturn,
                  onPressed: () => setState(() => confirmation = false),
                  gradient: AppColors.darkGradient,
                  padding: 36,
                  enabled: _resultList.isNotEmpty,
                ),
                visible: confirmation,
              ),
              GradientButton(
                text: locale.txtReportStorage,
                onPressed: () => _confirmBefore(),
                enabled: _resultList.isNotEmpty,
                showIcon: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            confirmation? locale.txtConfirmMissingInfo : '',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          InkWell(
            child: Padding(
              child: AppIcons.loadIcon(AppIcons.icClose, color: AppColors.colorBlue),
              padding: EdgeInsets.only(right: 16.0),
            ),
            onTap: () => Navigator.of(context).pop(null),
          ),
        ],
        leading: new Container(),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(confirmation? 95.0 : 32.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.blueGradient),
            ),
            alignment: Alignment.center,
            child: Text(
                confirmation? locale.msgConfirmMissingInfo : locale.txtSelectProductToCheckMissingInfo,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }
}