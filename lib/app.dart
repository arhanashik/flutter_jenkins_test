import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:o2o/ui/screen/splash/splash.dart';
import 'package:o2o/theme.dart';
import 'package:o2o/util/localization/o2o_localizations.dart';
import 'package:o2o/util/localization/o2o_localizations_delegate.dart';

class O2OApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (BuildContext context) => O2OLocalizations.of(
          context
      ).title,
      theme: buildTheme(),
      initialRoute: '/splash',
      routes: {
        // If you're using navigation routes, Flutter needs a base route.
        // We're going to change this route once we're ready with
        // implementation of HomeScreen.
//        '/': (context) => HomeScreen(),
        '/splash': (context) => SplashScreen(),
      },
      localizationsDelegates: [
        const O2OLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: O2OLocalizations.supportedLocales,
    );
  }
}
