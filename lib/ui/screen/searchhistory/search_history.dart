import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:o2o/data/constant/const.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/data/response/search_history_response.dart';
import 'package:o2o/data/timeorder/time_order_heading.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/error/error.dart';
import 'package:o2o/ui/screen/error/error_history_search_no_data.dart';
import 'package:o2o/ui/screen/orderlisthistory/oder_history_details.dart';
import 'package:o2o/ui/screen/searchhistory/search_history_barcode_scanner.dart';
import 'package:o2o/ui/screen/searchhistory/search_history_qrcode_scanner.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/common/app_images.dart';
import 'package:o2o/ui/widget/common/common_widget.dart';
import 'package:o2o/ui/widget/order_history_list_item.dart';
import 'package:o2o/util/helper/common.dart';
import 'package:o2o/util/helper/debouncer.dart';
import 'package:o2o/util/lib/remote/http_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../home/history/history_type.dart';

/// Created by mdhasnain on 07 Feb, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1.
/// 2.
/// 3.

enum SearchType {
  BARCODE, QR_CODE
}

class SearchHistoryScreen extends StatefulWidget{

  SearchHistoryScreen({
    Key key,
    this.searchQuery = '',
    this.hint,
    this.type = SearchType.BARCODE
  }): super(key: key);

  final String searchQuery;
  final String hint;
  final SearchType type;

  @override
  _SearchHistoryScreenState createState() => _SearchHistoryScreenState(
      searchQuery,
  );
}

class _SearchHistoryScreenState extends BaseState<SearchHistoryScreen> {
  _SearchHistoryScreenState(
      this._searchQuery,
  );

  final _searchHistory = LinkedHashMap<TimeOrderHeading,
      LinkedHashMap<HistoryType, List<OrderItem>>>();
  final _refreshController = RefreshController(initialRefresh: false);
  bool _isSearching = true;
  bool _showSearchInput = true;
  String _searchQuery = '';
  final _searchQueriesHistory = List<String>();
  TextEditingController _searchQueryController;
  final _deBouncer = Debouncer(milliseconds: 500);

  _loadSearchHistory() async {
    final queryHistory = await PrefUtil.read(
        widget.type == SearchType.QR_CODE? PrefUtil.QR_SEARCH_HISTORY
            : PrefUtil.JAN_SEARCH_HISTORY
    );
    if(queryHistory != null && queryHistory is List) {
      setState(() {
        _searchQueriesHistory.clear();
        _searchQueriesHistory.addAll(queryHistory.map((e) => e.toString()));
      });
    }
  }

  _buildAppBar() {
    return Text(
        '検索', style: TextStyle(color: Colors.black),
    );
  }

  _buildSearchBar() {
    return _showSearchInput? Container(
      height: 40.0,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.colorBlue, width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      padding: EdgeInsets.only(left: 8.0, bottom: 7.0),
      child: TextField(
        controller: _searchQueryController,
        autofocus: true,
        decoration: InputDecoration(
            isDense: true,
            hintText: widget.hint,
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black54, fontSize: 10.0),
            suffixIconConstraints: BoxConstraints(maxWidth: 28.0),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.grey,),
              padding: EdgeInsets.symmetric(vertical: 5.0),
              onPressed: () => _clearSearchQuery(),
            )
        ),
        cursorColor: Colors.black,
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.black, fontSize: 16.0),
        onChanged: (query) => _deBouncer.run(() {
          setState(() => _searchQuery = query);
          _filterResult();
        }),
      ),
    ) : Container();
  }
//
  _buildActions() {
    return Padding(
      padding: EdgeInsets.only(left: 5, right: 13),
      child: InkWell(
        child: Column(
          children: <Widget>[
            AppIcons.loadIcon(
                widget.type == SearchType.QR_CODE? AppIcons.icBarCode : AppIcons.icQrCode, color: AppColors.colorBlue, size: 20.0
            ),
            Padding(padding: EdgeInsets.only(top: 3),),
            Text(
              widget.type == SearchType.BARCODE? locale.txtReadBarcode : locale.txtReadQRCode,
              style: TextStyle(color: AppColors.colorBlueDark, fontSize: 10.0),
            )
          ],
        ),
        onTap: () => _returnToScanner(),
      ),
    );
  }

  _buildSearchSuggestion() {
    return ListView.separated(
      itemCount: _searchQueriesHistory.length,
      itemBuilder: (BuildContext context, int index) {
        final item = _searchQueriesHistory[index];
        return ListTile(
          title: Text(item),
          trailing: AppIcons.icArrowExport,
          onTap: () {
            _searchQueryController.text = item;
            _searchQueryController.selection = TextSelection.fromPosition(
                TextPosition(offset: _searchQueryController.text.length)
            );
            setState(() => _searchQuery = item);
            _filterResult();
            FocusScope.of(context).unfocus();
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 13.0),
          child: Divider(thickness: 1.2,),
        );
      },
    );
  }

  /// Builds the 'SliverStickyHeader' which consists of a 'TimeOrderHeading'
  /// and the 'TimeOrderItem' list under that header
  _buildPinnedHeaderList(TimeOrderHeading heading, List slivers) {
    return SliverStickyHeader(
      header: CommonWidget.sectionDateBuilder(
          heading.month, heading.day, heading.dayStr
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return slivers[index];
        },
          childCount: slivers.length,
        ),
      ),
    );
  }

  _buildSearchHistoryList() {
    final List<Widget> slivers = List();
    _searchHistory.forEach((heading, orderListsMap) {
      //in value there must have to be 3 lists.
      //1. delivered list
      //2. packing complete list
      //3. missing list
      final pinnedListSlivers = List<Widget>();
      orderListsMap.forEach((historyType, orderList) {
        if(orderList.isNotEmpty) {
          String title = '発送前';
          if(historyType == HistoryType.DELIVERED) title = '発送済み';
          if(historyType == HistoryType.STOCK_OUT) title = '欠品';
          final titleWidget = Container(
            height: 28,
            color: AppColors.colorBlue,
            padding: EdgeInsets.only(left: 13.0),
            alignment: Alignment.centerLeft,
            child: Text(
              title, style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          );

          pinnedListSlivers.add(titleWidget);
          orderList.forEach((orderItem) {
            final orderWidget = OrderHistoryListItem(
              context: context,
              orderItem: orderItem,
              historyType: historyType,
              onPressed:  () => _routeToOrderHistoryDetails(orderItem, historyType),
            );
            pinnedListSlivers.add(orderWidget);
          });
        }
      });

      slivers.add(_buildPinnedHeaderList(heading, pinnedListSlivers));
    });

    return slivers;
  }

  _buildResultList() {
    return loadingState == LoadingState.ERROR ? ErrorScreen(
        errorMessage: locale.errorMsgCannotGetData,
        btnText: locale.txtReload,
        onClickBtn: () => _filterResult(),
        showHelpTxt: true
    ) : loadingState == LoadingState.NO_DATA
        ? HistorySearchNoDataErrorScreen() : SmartRefresher(
      enablePullDown: true,
      header: ClassicHeader(
        idleText: locale.txtPullToRefresh,
        refreshingText: locale.txtRefreshing,
        completeText: locale.txtRefreshCompleted,
        releaseText: locale.txtReleaseToRefresh,
      ),
      child: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: _buildSearchHistoryList(),
      ),
      controller: _refreshController,
      onRefresh: () => _filterResult(),
    );
  }

  _bodyBuilder() {
    if(_isSearching) {
      if(_searchQuery.isEmpty) {
        if(_searchQueriesHistory.isEmpty) return Container();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 13, top: 10,),
              child: CommonWidget.sectionTitleBuilder(locale.txtRecentSearchHistory),
            ),
            Flexible(child: _buildSearchSuggestion(),)
          ],
        );
      }

      return _buildResultList();
    }

    return Container();
  }

  @override
  void initState() {
    super.initState();
    _searchQueryController = TextEditingController(text: _searchQuery);
    if(_searchQuery.isNotEmpty) {
      _searchQueryController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchQuery.length),
      );
      setState(() => _showSearchInput = false);
      _filterResult();
    }
    _loadSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: () => _returnToScanner(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          titleSpacing: 0.0,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(left: 13, right: 5,),
                  child: InkWell(
                    child: AppImages.loadSizedImage(
                        AppImages.icStopUrl, height: 32.0, width: 28.0
                    ),
                    onTap: () => _returnToScanner(),
                  )
              ),
              Flexible(child: _isSearching? _buildSearchBar() : _buildAppBar(),),
              _buildActions(),
            ],
          ),
        ),
        body: _bodyBuilder(),
      ),
    );
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    super.dispose();
  }

  void _startSearch() {
    ModalRoute
        .of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() => _isSearching = true);
  }

  void _stopSearching() {
    _clearSearchQuery();
    setState(() => _isSearching = false);
  }

  void _clearSearchQuery() {
    _searchQueryController.clear();
    setState(() => _searchQuery = '');
  }

  _filterResult() async {
    _searchHistory.clear();

    if(_searchQuery.isEmpty) {
      setState(() => loadingState = LoadingState.NO_DATA);
      return;
    }

    //save the latest search query
    _saveSearchQuery(_searchQuery);

    String imei = await PrefUtil.read(PrefUtil.SERIAL_NUMBER);
    final params = HashMap();
    params[Params.SERIAL] = imei;
    if(widget.type == SearchType.QR_CODE) params[Params.QR_CODE] = _searchQuery;
    else params[Params.JAN_CODE] = _searchQuery;

    String url = HttpUtil.SEARCH_HISTORY_BY_JAN_CODE;
    if(widget.type == SearchType.QR_CODE)
      url = HttpUtil.SEARCH_HISTORY_BY_QR_CODE;
    final response = await HttpUtil.get(url, params: params);
    _refreshController.refreshCompleted();
    if (response.statusCode != HttpCode.OK) {
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }
    final responseMap = json.decode(response.body);
    final code = responseMap[Params.CODE];
    if(code != HttpCode.OK) {
      setState(() => loadingState = LoadingState.ERROR);
      return;
    }
    final data = responseMap[Params.DATA];
    final searchResults = data.map(
            (data) => SearchHistoryResponse.fromJson(data)
    ).toList();

    LoadingState newState = LoadingState.NO_DATA;
    if (searchResults.isNotEmpty) {
      for (int i = 0; i < searchResults.length; i++) {
        final searchResult = searchResults[i];
        if(searchResult is SearchHistoryResponse) {
          final dateTime = Common.convertToDateTime(searchResult.date);
          final header = TimeOrderHeading(
            dateTime.day, dateTime.month, AppConst.WEEKDAYS[dateTime.weekday-1],
          );

          final planning = List<OrderItem>();
          final delivered = List<OrderItem>();
          final stockOutList = List<OrderItem>();
          searchResult.searchOrderList.forEach((orderItem) {
            if(orderItem is OrderItem) {
            if(orderItem.flag == SearchOrderFlag.PACKING_COMPLETE)
              planning.add(orderItem);
            else if(orderItem.flag == SearchOrderFlag.DELIVERED)
              delivered.add(orderItem);
            else if(orderItem.flag == SearchOrderFlag.MISSING)
              stockOutList.add(orderItem);
            }
          });

          final items = LinkedHashMap<HistoryType, List<OrderItem>>();
          items[HistoryType.PLANNING] = planning;
          items[HistoryType.DELIVERED] = delivered;
          items[HistoryType.STOCK_OUT] = stockOutList;

          _searchHistory[header] = items;
        }
      }

      newState = LoadingState.OK;
    }

    setState(() => loadingState = newState);
  }

  _saveSearchQuery(String searchQuery) async {
    if(_searchQueriesHistory.contains(searchQuery)) {
      _searchQueriesHistory.remove(searchQuery);
    }

    _searchQueriesHistory.insert(0, searchQuery);
    if(_searchQueriesHistory.length > 6) {
      _searchQueriesHistory.removeRange(5, _searchQueriesHistory.length);
    }
    await PrefUtil.save(
        widget.type == SearchType.QR_CODE
            ? PrefUtil.QR_SEARCH_HISTORY : PrefUtil.JAN_SEARCH_HISTORY,
        _searchQueriesHistory
    );
  }

  _routeToOrderHistoryDetails(orderItem, historyType) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => OrderHistoryDetailsScreen(
            orderItem, historyType
        ))
    );
  }

  _returnToScanner() async {
    //hide keyboard first if it is open
    if(MediaQuery.of(context).viewInsets.bottom > 0) {
      FocusScope.of(context).unfocus();
      return;
    }

    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => widget.type == SearchType.BARCODE
            ? SearchHistoryBarcodeScannerScreen() : SearchHistoryQrCodeScannerScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}