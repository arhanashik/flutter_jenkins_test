import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';

class Step5QrCodeListDialog extends StatefulWidget {
  Step5QrCodeListDialog({this.items});
  final List<String> items;

  @override
  Step5QrCodeListDialogState createState() => new Step5QrCodeListDialogState(items);
}

class Step5QrCodeListDialogState extends BaseState<Step5QrCodeListDialog> {

  Step5QrCodeListDialogState(this._items);

  List<String> _items = List();
  LinkedHashSet<String> _resultList = LinkedHashSet();

  void _onItemChecked(bool checked, item) {
    if (checked == true) {
      setState(() {
        _resultList.add(item);
      });
    } else {
      setState(() {
        _resultList.remove(item);
      });
    }
  }

  _confirmAddNew() {
    String msg = 'QRコード読み取り画面に\n戻ります。よろしいですか？';
    ConfirmationDialog(
        context,
        'QRコード読み取り作業に戻ります',
        msg,
        locale.txtOk,
            () => Navigator.of(context).pop(_items.toList())
    ).show();
  }

  _confirmBefore() {
    bool isPrimaryQrCodeDelete = _resultList.contains(_items[0]);
    String msg = (isPrimaryQrCodeDelete? locale.msgDeletePrimaryQrCodes : locale.msgDeleteQrCodes) + '\n\n' +
        locale.txtQrCodeNumber + '\n' + _resultList.join('\n');
    ConfirmationDialog(
        context,
        locale.txtConfirm,
        msg,
        locale.txtOk, () {
          setState(() {
            _resultList.forEach((_item) => _items.remove(_item));
          });
          Navigator.of(context).pop(_resultList.toList());
          _resultList.clear();
    }).show();
  }

  _sectionTitleBuilder(title) {
    return Container(
      margin: EdgeInsets.only(left: 16.0, top: 16.0),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(width: 3.0, color: Colors.lightBlue)),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Text(
          title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  _actionButtonBuilder() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 56, vertical: 0),
          child: GradientButton(
            text: "QRコードを追加で読み取る",
            onPressed: () {
              _confirmAddNew();
            },
            showIcon: true,
            icon: Icon(Icons.add, size: 24.0, color: Colors.white,),
            borderRadius: 24.0,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 56,),
          child: GradientButton(
            text: "QRコードを削除する",
            onPressed: () {
              _confirmBefore();
            },
            enabled: _resultList.isNotEmpty,
            showIcon: true,
            icon: Icon(
              Icons.delete,
              size: 24.0,
              color: _resultList.isEmpty? Colors.grey : Colors.black,
            ),
            borderRadius: 24.0,
            txtColor: Colors.black,
            disableTxtColor: Colors.grey,
            gradient: AppColors.btnGradientLight,
          ),
        ),
        Padding(padding: EdgeInsets.only(bottom: 16),)
      ],
    );
  }

  _buildBody() {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        ListView.builder(
            itemCount: _items.length + 2,
            itemBuilder: (BuildContext context, int index) {
              if(index == 0) {
                return Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.blueGradient),
                    border: Border(bottom: BorderSide(color: Colors.black12))
                  ),
                  padding: EdgeInsets.all(16,),
                  alignment: Alignment.center,
                  child: Text(
                    '読み取った配送ラベルの\nQRコードを編集できます。',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if(index == 1) {
                return _sectionTitleBuilder(
                    '${locale.txtQRScannedLabeledCount}: ${_items.length}'
                );
              }

              final item = _items[index - 2];
              return CheckboxListTile(
                value: _resultList.contains(item),
                onChanged: (bool selected) {
                  _onItemChecked(selected, item);
                },
                title: Text(item),
                controlAffinity: ListTileControlAffinity.leading,
              );
            }
        ),
        _actionButtonBuilder(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.white,
        elevation: 0.0,
        actions: <Widget>[
          InkWell(
            child: Padding(
              child: AppIcons.loadIcon(AppIcons.icClose, color: AppColors.colorBlue),
              padding: EdgeInsets.only(right: 16.0),
            ),
            onTap: () => Navigator.of(context).pop(null),
          ),
        ],
        leading: Container(),
      ),
      body: _buildBody(),
    );
  }
}