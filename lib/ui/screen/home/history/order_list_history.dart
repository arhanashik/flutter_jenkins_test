import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/timeorder/time_order.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/home/history/oder_history_details.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/order_history_list_item.dart';

/// Created by mdhasnain on 06 Feb, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1.
/// 2.
/// 3.

class OrderListHistoryScreen extends StatefulWidget {

  OrderListHistoryScreen(this.title, this.timeOrder, this.historyType);

  final String title;
  final TimeOrder timeOrder;
  final HistoryType historyType;

  @override
  _OrderListHistoryScreenState createState() => _OrderListHistoryScreenState(
    title, timeOrder, historyType,
  );
}

enum HistoryType {
  PLANNING, COMPLETE, MISSING
}

class _OrderListHistoryScreenState extends BaseState<OrderListHistoryScreen> {

  _OrderListHistoryScreenState(this.title, this.timeOrder, this.historyType);
  final String title;
  final TimeOrder timeOrder;
  final HistoryType historyType;

  List _orderHistoryList = new List();
  var isLoading = false;
  String nextPage = "https://swapi.co/api/people";

  fetchData() async {
    if (loadingState == LoadingState.LOADING) return;

    setState(() => loadingState = LoadingState.LOADING);

    List tempList = OrderItem.dummyOrderItems();

    LoadingState newState = LoadingState.NO_DATA;
    if (_orderHistoryList.isNotEmpty || tempList.isNotEmpty) {
      newState = LoadingState.OK;

      _orderHistoryList.addAll(tempList);
    }

    setState(() => loadingState = newState);
  }

  ScrollController scrollController;

  _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      fetchData();
    }
//    if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
//      fetchData();
//    }
  }

  Widget _buildList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: _orderHistoryList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == _orderHistoryList.length) {
          return CommonWidget.buildProgressIndicator(loadingState);
        }

        return OrderHistoryListItem(
          context: context,
          orderItem: _orderHistoryList[index],
          historyType: historyType,
          onPressed:  () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => OrderHistoryDetailsScreen(
                    title, _orderHistoryList[index], historyType
                )
            ));
          },
        );
      },
      controller: scrollController,
    );
  }

  @override
  void initState() {
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    String titleLeading = '発送前';
    if(historyType == HistoryType.COMPLETE) titleLeading = '発送済み';
    if(historyType == HistoryType.MISSING) titleLeading = '欠品';

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 230, 242, 255),
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              color: AppColors.background,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                titleLeading,
                style: TextStyle(fontSize: 14, color: AppColors.colorBlueDark),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 10),),
            Text(locale.homeNavigation2Title),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(32.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.blueGradient),
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: _buildList(),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}