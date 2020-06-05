import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:o2o/ui/screen/splash/splash.dart';
import 'package:o2o/theme.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';
import 'package:o2o/util/helper/localization/o2o_localizations_delegate.dart';

///This is where everything begins.
/// Created by mdhasnain
/// Email: md.hasnain@healthcare-tech.co.jp
///
/// Purpose of the class:
/// 1. Returning Material App to main.dart
/// 2. Generating localized title
/// 3. Customising theme
/// 4. Declaring and calling initial Route(Splash Screen)
/// 5. Declaring and initialing localization

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
