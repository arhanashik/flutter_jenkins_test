import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/dialog/confirmation_dialog.dart';

class Step4QrCodeListDialog extends StatefulWidget {
  Step4QrCodeListDialog({this.items});
  final List<String> items;

  @override
  createState() => _Step4QrCodeListDialogState(items);
}

class _Step4QrCodeListDialogState extends BaseState<Step4QrCodeListDialog> {

  _Step4QrCodeListDialogState(this._items);

  List<String> _items = List();
  final _resultList = LinkedHashSet();

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

  _confirmBefore() {
    String msg = locale.msgDeleteSelectedQrCodes + '\n\n' +
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
                    locale.txtCheckQrCodeToDelete,
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
        Container(
          height: 48.0,
          margin: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: GradientButton(
            text: locale.txtDeleteSelectedQrCodes,
            onPressed: () {
              _confirmBefore();
            },
            enabled: _resultList.isNotEmpty,
            showIcon: true,
            icon: Icon(Icons.play_circle_filled, size: 28.0,),
            borderRadius: 24.0,
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