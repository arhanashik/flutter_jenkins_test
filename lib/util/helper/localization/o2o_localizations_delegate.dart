import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:o2o/util/helper/localization/o2o_localizations.dart';

class O2OLocalizationsDelegate extends LocalizationsDelegate<O2OLocalizations> {
  const O2OLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      O2OLocalizations.supportedLanguages.contains(locale.languageCode);

  @override
  Future<O2OLocalizations> load(Locale locale) {
    return SynchronousFuture<O2OLocalizations>(O2OLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<O2OLocalizations> old) => false;
}
