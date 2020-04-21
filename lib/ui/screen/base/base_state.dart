import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/data/pref/pref.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';
import 'package:o2o/util/lib/fcm/fcm_manager.dart';
import 'package:o2o/util/lib/notification/notification_manager.dart';

/// Created by mdhasnain on 01 Feb, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Base state class for all the Stateful Widget
/// 2. Provides localization, loadingState, connectivity from single place
/// 3. Safeguard the setState() method from single place

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  /// Locale text provider
  O2OLocalizations locale;

  /// Data loading state from the remote
  LoadingState loadingState;

  /// Connectivity state of the device(Internet, Wifi, No Connection)
  final _connectivity = Connectivity();
  /// For listening to the the connectivity change
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  /// the internet connectivity status
  bool isOnline = false;
  void onConnectionChanged(bool isConnected) {
    _showConnectionView(!isConnected);
  }

  /// initialize connectivity checking
  /// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initConnectivity() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    await _updateConnectionStatus().then((isConnected) => setState(() {
      isOnline = isConnected;
    }));
  }

  /// Lookup to 'google.com' to check the device's internet availability
  Future<bool> _updateConnectionStatus() async {
    bool isConnected;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
    }
    return isConnected;
  }

  /// Builds the No Connection View if internet/wifi is not available
  _buildNoConnectionView() {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0.0,
        width: MediaQuery.of(context).size.width,
        child: Material(
          elevation: 10.0,
          child: Container(
            color: Colors.redAccent,
            padding: EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: Text(
              'Connection not available',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Show hide the overlay Connection View
  OverlayEntry _noConnectionView;
  bool _isNoConnectionViewVisible = false;
  void _showConnectionView(bool show) {
    if(_noConnectionView == null) _noConnectionView = _buildNoConnectionView();

    if(show) Overlay.of(context).insert(_noConnectionView);
    else {
      if(_isNoConnectionViewVisible) _noConnectionView.remove();
    }
    _isNoConnectionViewVisible = show;
  }

  /// Default initState
  @override
  void initState() {
    super.initState();
    //Init local notification manager
    NotificationManager().init();

    //Init Firebase Notification Observer
    FcmManager().init();

    // Init internet connectivity observer
    _initConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      await _updateConnectionStatus().then((isConnected) {
        setState(() => isOnline = isConnected);
        onConnectionChanged(isConnected);
      });
    });
  }

  /// Default build Function for initialing localization
  @override
  Widget build(BuildContext context) {
    locale = O2OLocalizations.of(context);

    return null;
  }

  /// Safeguard the setState() method
  @override
  void setState(fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void dispose() {
    // Removing the subscription of connectivity listener
    _connectivitySubscription.cancel();
    super.dispose();
  }
}