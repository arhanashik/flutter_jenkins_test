import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/timeorder/time_order_heading.dart';
import 'package:o2o/data/timeorder/time_order_list_item.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/error/error.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/time_order_item.dart';
import 'package:o2o/util/HttpUtil.dart';

/// Created by mdhasnain on 28 Jan, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Shows the list of orders
/// 2.
/// 3.

class TimeOrderListScreen extends StatefulWidget {
  @override
  _TimeOrderListScreenState createState() => _TimeOrderListScreenState();
}

class _TimeOrderListScreenState extends BaseState<TimeOrderListScreen> {
  List timeOrders = List();
  String nextPage = "https://swapi.co/api/people";

  _fetchData() async {
    if (loadingState == LoadingState.LOADING) return;

    setState(() => loadingState = LoadingState.LOADING);

    String imei = await PrefUtil.read(PrefUtil.IMEI);
    final requestBody = HashMap();
    requestBody['imei'] = imei;

    final response = await HttpUtil.postReq(AppConst.GET_TIME_ORDER, requestBody);
//    print('code: ${response.statusCode}, body: ${response.body}');
    print('code: ${response.statusCode}');
    if (response.statusCode != 200) {
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }

    List jsonData = json.decode(response.body);
    List<TimeOrderListItem> items = jsonData.map(
            (data) => TimeOrderListItem.fromJson(data)
    ).toList();

    LoadingState newState = LoadingState.NO_DATA;
    if (timeOrders.isNotEmpty || jsonData.isNotEmpty) {
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        String rawDate = item.date;
        final dateTime = DateTime.parse(rawDate);
        timeOrders.add(TimeOrderHeading(
            dateTime.day, dateTime.month, AppConst.WEEKDAYS[dateTime.weekday],
        ));
        timeOrders.addAll(item.timeOrderList);
      }

      newState = LoadingState.OK;
    }

    setState(() => loadingState = newState);
  }

  ScrollController scrollController;

  _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
//      _fetchData();
    }
//    if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
//      fetchData();
//    }
  }

  Container _sectionTitleBuilder() {
    return Container(
      height: 60,
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AppIcons.loadIcon(AppIcons.icList, color: AppColors.colorBlue),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              locale.homeNavigation1Title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

  Widget _bodyBuilder() {

    return loadingState == LoadingState.ERROR
        ? ErrorScreen(
        errorMessage: locale.errorMsgCannotGetData,
        btnText: locale.txtReload,
        onClickBtn: () => _fetchData(),
        showHelpTxt: true
    ) : loadingState == LoadingState.NO_DATA
        ? ErrorScreen(
      errorMessage: locale.errorMsgNoData,
      btnText: locale.refreshOrderList,
      onClickBtn: () => _fetchData(),

    ) : ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: timeOrders.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == timeOrders.length) {
          return CommonWidget.buildProgressIndicator(loadingState);
        } else {
          final currentItem = timeOrders[index];
          if (currentItem is TimeOrderHeading) {
            return CommonWidget.sectionDateBuilder(
                currentItem.month, currentItem.day, currentItem.dayStr);
          }
          return TimeOrderItem(context: context, timeOrder: timeOrders[index]);
        }
      },
      controller: scrollController,
    );
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _sectionTitleBuilder(),
      ),
      body: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    scrollController?.dispose();
    super.dispose();
  }
}
