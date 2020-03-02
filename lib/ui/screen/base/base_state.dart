import 'package:flutter/cupertino.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/util/localization/o2o_localizations.dart';

/// Created by mdhasnain on 01 Feb, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Base state class for all the Stateful Widget
/// 2. Provides localization and loadingState from single place
/// 3. Safeguard the setState() method from single place

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  // Locale text provider
  O2OLocalizations locale;

  // Data loading state from the remote
  LoadingState loadingState;

  // Default buildFunction for initialing localization
  @override
  Widget build(BuildContext context) {
    locale = O2OLocalizations.of(context);

    return null;
  }

  // Safeguard the setState() method
  @override
  void setState(fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}