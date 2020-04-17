import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/home/history/history.dart';
import 'package:o2o/ui/screen/home/timeorder/time_order_list.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';

/// Created by mdhasnain on 27 Jan, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Home screen of the application
/// 2. Container for the navigation between time order list and history
/// 3.

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen> {
  // Index of the current widget
  int _currentIndex = 0;

  // Widgets for the HomeScreen
  List<Widget> _bodyItems = [
    TimeOrderListScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: SafeArea(child: IndexedStack(
        index: _currentIndex,
        children: _bodyItems,
      )),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 16,
        items: [
          BottomNavigationBarItem(
//            icon: Icon(Icons.assignment),
            icon: AppIcons.loadSizedIcon(AppIcons.icList, size: 18.0),
            title: Text(
              locale.homeNavigation1,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          BottomNavigationBarItem(
//            icon: Icon(Icons.access_time),
            icon: AppIcons.loadSizedIcon(AppIcons.icClock, size: 18.0),
            title: Text(
              locale.homeNavigation2,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {_currentIndex = index;}),
      ),
    );
  }

}