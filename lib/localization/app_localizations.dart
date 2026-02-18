import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  late Map<String, dynamic> _localizedStrings;

  AppLocalizations(this._localizedStrings);

  static AppLocalizations? _instance;

  static Future<AppLocalizations> load(String locale) async {
    final jsonString = await rootBundle.loadString('localization/$locale.json');
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    _instance = AppLocalizations(jsonMap);
    return _instance!;
  }

  static AppLocalizations get instance => _instance ?? AppLocalizations({});

  String translate(String key) {
    try {
      final keys = key.split('.');
      dynamic value = _localizedStrings;

      for (final k in keys) {
        if (value is Map) {
          value = value[k];
        } else {
          return key;
        }
      }

      return value?.toString() ?? key;
    } catch (e) {
      print('Translation error for key: $key');
      return key;
    }
  }

  // Helper method for common translations
  String trans(String key) => translate(key);
}

class AppLocalizationsDelegate {
  static const supportedLocales = [Locale('en'), Locale('fr')];
  static const fallbackLocale = Locale('en');

  static const Map<String, String> languageNames = {
    'en': 'English',
    'fr': 'Français',
  };

  static String getLanguageName(String locale) {
    return languageNames[locale] ?? locale;
  }

  static String getLanguageCode(Locale locale) {
    return locale.languageCode;
  }
}

extension on Locale {
}

// Global helper function
String tr(String key) {
  return AppLocalizations.instance.translate(key);
}
