import 'package:flutter/material.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/widget/packing_product_item.dart';

class FullScreenOrderListDialog extends StatefulWidget {
  FullScreenOrderListDialog({this.items});

  final List items;

  @override
  FullScreenOrderListDialogState createState() => new FullScreenOrderListDialogState(items);
}

class FullScreenOrderListDialogState extends BaseState<FullScreenOrderListDialog> {

  FullScreenOrderListDialogState(this._items);

  List _items = List();

  _buildBody() {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: _items.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: PackingProductItem(product: _items[index],),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.txtProductList,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: new Icon(Icons.close, color: Colors.white,),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
        leading: new Container(),
      ),
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }
}
