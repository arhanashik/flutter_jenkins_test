import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/home/history/history_list.dart';
import 'package:o2o/ui/screen/searchhistory/search_history_barcode_scanner.dart';
import 'package:o2o/ui/screen/searchhistory/search_history_qrcode_scanner.dart';
import 'package:o2o/ui/widget/button/gradient_button.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';

import 'history_type.dart';

/// Created by mdhasnain on 04 Jan, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Shows the list of orders
/// 2.
/// 3.

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final ImageIcon icon;
}

class _HistoryScreenState extends BaseState<HistoryScreen> {

  int _currentPage = 0;
  PageController _pageController;
  _pageScrollListener() {
    setState(() => _currentPage = _pageController.page.ceil());
  }
  final _pages = List();
  _initPages() {
    _pages.clear();
    _pages.add(HistoryListScreen(historyType: HistoryType.PLANNING,));
    _pages.add(HistoryListScreen(historyType: HistoryType.DELIVERED,));
    _pages.add(HistoryListScreen(historyType: HistoryType.STOCK_OUT,));
  }

  List<Choice> _choices = List();
  Choice _selectedChoice;
  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
    });

    if(_selectedChoice == _choices[0]) _scanBarcode();
    if(_selectedChoice == _choices[1]) _scanQrCode();
  }

  void _initChoices() {
    _choices.clear();
    _choices.add(Choice(
            title: locale.txtReadBarcode, icon: AppIcons.loadIcon(
            AppIcons.icBarCode, color: AppColors.colorBlue, size: 18.0
        ))
    );
    _choices.add(Choice(
            title: locale.txtReadQRCode, icon: AppIcons.loadIcon(
            AppIcons.icQrCode, color: AppColors.colorBlue, size: 18.0
        ))
    );

    _selectedChoice = _choices[0];
  }

   _sectionTitleBuilder() {
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: <Widget>[
        Container(
          height: 60,
          color: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                locale.homeNavigation2Title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              child: Column(
                children: <Widget>[
                  _choices[0].icon,
                  Padding(padding: EdgeInsets.only(top: 3),),
                  Text(
                    'バーコード読取',
                    style: TextStyle(color: AppColors.colorBlueDark, fontSize: 10.0),
                  )
                ],
              ),
              onTap: () => _select(_choices[0]),
            ),
            Padding(padding: EdgeInsets.only(left: 8),),
            InkWell(
              child: Column(
                children: <Widget>[
                  _choices[1].icon,
                  Padding(padding: EdgeInsets.only(top: 3),),
                  Text(
                    'QR読取',
                    style: TextStyle(color: AppColors.colorBlueDark, fontSize: 10.0),
                  )
                ],
              ),
              onTap: () => _select(_choices[1]),
            ),
          ],
        )
      ],
    );
  }

  _buildControlBtn(
      int btnIndex,
      String txt, {
        EdgeInsets padding: const EdgeInsets.symmetric(horizontal: 32.0,),
  }) {
    return Container(
      height: 36.0,
      decoration: _buildControlBtnBorder(btnIndex),
      child: GradientButton(
        text: txt,
        txtColor: _currentPage == btnIndex? Colors.white : Colors.black,
        fontWeight: FontWeight.w800,
        onPressed: () => _scrollToPage(btnIndex),
        gradient: _currentPage == btnIndex? AppColors.btnGradient : AppColors.lightGradient,
        borderRadius: 5.0,
        padding: padding,
      ),
    );
  }

  _buildControlBtnBorder(int btnIndex) {
    return _currentPage == btnIndex? null : BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    );
  }

  _controllerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildControlBtn(0, locale.txtBeforeShipping),
        _buildControlBtn(1, locale.txtShippingDone),
        _buildControlBtn(2, locale.txtMissing),
      ],
    );
  }

  /*
  * This function is used to manually scroll the page view.
  * In this function we set the _currentPage value manually.
  * Reason is animateToPage scrolls via all pages on the path.
  * So there is a glitch like each button on the path is clicked.
  * That's why we are removing the listener first so that the button state
  * doesn't get called automatically. After our manual scroll we add the
  * listener again.
  * */
  _scrollToPage(int page) async {
    setState(() => _currentPage = page);
    _pageController.removeListener(_pageScrollListener);
//    _pageController.jumpToPage(page);
    await _pageController.animateToPage(
        page, duration: Duration(milliseconds: 250), curve: Curves.decelerate
    );
    _pageController.addListener(_pageScrollListener);
  }

  _bodyBuilder() {
    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, position) {
        return _pages[position];
      },
      itemCount: 3,
      physics: BouncingScrollPhysics(),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_pageScrollListener);

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _initChoices();
    _initPages();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _sectionTitleBuilder(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Container(
            height: 56.0,
            color: AppColors.colorF1F1F1,
            child: _controllerButtons(),
          ),
        ),
      ),
      body: _bodyBuilder(),
    );
  }

  _scanQrCode() async {
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => SearchHistoryQrCodeScannerScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  _scanBarcode() async {
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => SearchHistoryBarcodeScannerScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}