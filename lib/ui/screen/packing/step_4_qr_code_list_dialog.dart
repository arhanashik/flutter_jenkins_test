import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
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
                return Padding(
                  padding: EdgeInsets.only(left: 16, top: 16,),
                  child: CommonWidget.sectionTitleBuilder(
                      '${locale.txtQRScannedLabeledCount}: ${_items.length}'
                  ),
                );
              }

              final item = _items[index - 2];
              return Container(
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      value: _resultList.contains(item),
                      onChanged: (bool selected) {
                        _onItemChecked(selected, item);
                      },
                    ),
                    Text(
                      item,
                      style: TextStyle(fontSize: 16.0,),
                    ),
                  ],
                ),
              );
              return CheckboxListTile(
                value: _resultList.contains(item),
                onChanged: (bool selected) {
                  _onItemChecked(selected, item);
                },
                title: Text(
                  item,
                  style: TextStyle(fontSize: 16.0,),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              );
            }
        ),
        Container(
          height: 40.0,
          margin: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          child: GradientButton(
            text: locale.txtDeleteSelectedQrCodes,
            onPressed: () {
              _confirmBefore();
            },
            enabled: _resultList.isNotEmpty,
            showIcon: true,
            borderRadius: 24.0,
            height: 40.0,
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