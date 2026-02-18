import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_localizations.dart';

class LocalizationProvider extends ChangeNotifier {
  late Locale _currentLocale;
  late AppLocalizations _appLocalizations;

  Locale get currentLocale => _currentLocale;
  AppLocalizations get appLocalizations => _appLocalizations;

  LocalizationProvider() {
    _currentLocale = AppLocalizationsDelegate.fallbackLocale;
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('language_code') ?? 'en';
    await setLocale(Locale(savedLocale));
  }

  Future<void> setLocale(Locale locale) async {
    if (!AppLocalizationsDelegate.supportedLocales.contains(locale)) {
      return;
    }

    try {
      final appLocalizations = await AppLocalizations.load(locale.languageCode);
      _appLocalizations = appLocalizations;
      _currentLocale = locale;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);

      notifyListeners();
    } catch (e) {
      print('Error loading locale: $e');
    }
  }

  Future<void> toggleLocale() async {
    if (_currentLocale.languageCode == 'en') {
      await setLocale(const Locale('fr'));
    } else {
      await setLocale(const Locale('en'));
    }
  }

  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isFrench => _currentLocale.languageCode == 'fr';

  String get currentLanguageName {
    return AppLocalizationsDelegate.getLanguageName(_currentLocale.languageCode);
  }
}
