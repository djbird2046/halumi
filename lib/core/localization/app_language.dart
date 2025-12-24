import 'package:flutter/widgets.dart';

enum AppLanguage { system, chinese, english }

extension AppLanguageX on AppLanguage {
  String get storageValue {
    switch (this) {
      case AppLanguage.chinese:
        return 'zh';
      case AppLanguage.english:
        return 'en';
      case AppLanguage.system:
        return 'system';
    }
  }

  Locale? get locale {
    switch (this) {
      case AppLanguage.chinese:
        return const Locale('zh');
      case AppLanguage.english:
        return const Locale('en');
      case AppLanguage.system:
        return null;
    }
  }
}

AppLanguage appLanguageFromStorage(String value) {
  switch (value) {
    case 'zh':
      return AppLanguage.chinese;
    case 'en':
      return AppLanguage.english;
    case 'system':
    default:
      return AppLanguage.system;
  }
}
