import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o2o/data/orderitem/order_item.dart';
import 'package:o2o/ui/screen/base/base_state.dart';
import 'package:o2o/ui/screen/home/history/oder_history_details.dart';
import 'package:o2o/ui/screen/home/history/order_list_history.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';
import 'package:o2o/ui/widget/common/app_icons.dart';
import 'package:o2o/ui/widget/order_history_list_item.dart';
import 'package:o2o/util/helper/debouncer.dart';

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

class SearchHistory extends StatefulWidget{

  SearchHistory({
    Key key,
    this.searchQuery = '',
    this.hint,
    this.type = SearchType.BARCODE
  }): super(key: key);

  final String searchQuery;
  final String hint;
  final SearchType type;

  @override
  _SearchHistoryState createState() => _SearchHistoryState(
      searchQuery, hint, type
  );
}

class _SearchHistoryState extends BaseState<SearchHistory> {
  _SearchHistoryState(
      this._searchQuery,
      this._hint,
      this._type
  );

  List _timeOrders = List();
  List _shippingCompletedList = List();
  List _missingList = List();
  List<String> _searchHistoryList = List();

  List _filteredTimeOrders = List();
  List _filteredShippingCompletedList = List();
  List _filteredMissingList = List();

  bool _isSearching = true;
  String _searchQuery = '';
  TextEditingController _searchQueryController;
  final _deBouncer = Debouncer(milliseconds: 500);

  final String _hint;
  final SearchType _type; 

  _loadSearchHistory() {
    _searchHistoryList.add('12345678');
    _searchHistoryList.add('3225235252');
    _searchHistoryList.add('234235536666');
    _searchHistoryList.add('324353532');

    List tempList = OrderItem.dummyOrderItems();

    _timeOrders.addAll(tempList);
    _shippingCompletedList.addAll(tempList);
    _missingList.addAll(tempList);
  }

  _sectionTitleBuilder(title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.blueGradient),
      ),
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        padding: EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(width: 3.0, color: Colors.white)),
        ),
        child: Text(
          title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  _buildAppBar() {
    return Text(
        '検索',
      style: TextStyle(color: Colors.black),
    );
  }

  _buildSearchBar() {
    return Container(
      height: 40.0,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.colorBlue, width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      padding: EdgeInsets.only(left: 8.0),
      child: TextField(
        controller: _searchQueryController,
        autofocus: true,
        decoration: InputDecoration(
          isDense: true,
            hintText: _hint,
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black54, fontSize: 12.0),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
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
    );
  }
//
//  _buildActions() {
//    if (_isSearching) {
//      return <Widget>[
//        IconButton(
//          icon: const Icon(Icons.clear),
//          onPressed: () {
//            if (_searchQueryController == null || _searchQueryController.text.isEmpty) {
//              Navigator.pop(context);
//              return;
//            }
//            _clearSearchQuery();
//          },
//        ),
//      ];
//    }
//
//    return <Widget>[
//      IconButton(
//        icon: const Icon(Icons.search),
//        onPressed: _startSearch,
//      ),
//    ];
//  }

  _buildSearchSuggestion() {
    return ListView.separated(
      itemCount: _searchHistoryList.length,
      itemBuilder: (BuildContext context, int index) {
        final item = _searchHistoryList[index];
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
        return Divider(thickness: 1.3,);
      },
    );
  }

  _buildDetailsScreenTitle(historyType) {
    String title = '12月10日 (金) 13:00に';
    if(historyType == HistoryType.PLANNING) title += '発送予定の注文';
    else if(historyType == HistoryType.COMPLETE) title += '発送済みの注文';
    else if(historyType == HistoryType.MISSING) title += '欠品報告をした注文';

    return title;
  }

  _routeToOrderHistoryDetails(orderItem, historyType) {
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => OrderHistoryDetailsScreen(
                _buildDetailsScreenTitle(historyType),
                orderItem,
                historyType
            )
        )
    );
  }

  _buildSliverList(List items, historyType) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        final item = items[index];
        return OrderHistoryListItem(
          context: context,
          orderItem: item,
          historyType: historyType,
          onPressed: () => _routeToOrderHistoryDetails(item, historyType),
        );
      }, childCount: items.length,),
    );
  }

  _buildResultList() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverVisibility(
          sliver: SliverToBoxAdapter(
            child: _sectionTitleBuilder(locale.txtShippingPreparationComplete),
          ),
          visible: _filteredTimeOrders.isNotEmpty,
        ),
        _buildSliverList(_filteredTimeOrders, HistoryType.PLANNING),
        SliverVisibility(
          sliver: SliverToBoxAdapter(
            child: _sectionTitleBuilder(locale.txtShippingDone),
          ),
          visible: _filteredShippingCompletedList.isNotEmpty,
        ),
        _buildSliverList(_filteredShippingCompletedList, HistoryType.COMPLETE),
        SliverVisibility(
          sliver: SliverToBoxAdapter(
            child: _sectionTitleBuilder(locale.txtMissing),
          ),
          visible: _filteredMissingList.isNotEmpty,
        ),
        _buildSliverList(_filteredMissingList, HistoryType.MISSING),
      ],
    );
  }

  _bodyBuilder() {
    if(_isSearching) {
      if(_searchQuery.isEmpty) {
        return Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                locale.txtRecentSearchHistory,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ),
              ),
            ),
            Flexible(
              child: _buildSearchSuggestion(),
            )
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
    _loadSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0.0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.colorBlue),
              onPressed: () => Navigator.pop(context),
            ),
            Flexible(child: _isSearching? _buildSearchBar() : _buildAppBar(),),
            IconButton(
              icon: AppIcons.loadIcon(
                  _type == SearchType.BARCODE? AppIcons.icBarCode : AppIcons.icQrCode,
                  color: AppColors.colorBlue
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: _bodyBuilder(),
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

  _filterResult() {
    _filteredTimeOrders.clear();
    _filteredShippingCompletedList.clear();
    _filteredMissingList.clear();

    if(_searchQuery.isEmpty) return;

    _filteredTimeOrders.addAll(_timeOrders.where(
            (element) => element is OrderItem && element.orderId.toString().contains(_searchQuery)
    ));

    _filteredShippingCompletedList.addAll(_shippingCompletedList.where(
            (element) => element is OrderItem && element.orderId.toString().contains(_searchQuery)
    ));

    _filteredMissingList.addAll(_missingList.where(
            (element) => element is OrderItem && element.orderId.toString().contains(_searchQuery)
    ));
  }
}