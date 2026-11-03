import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/maydan_repository.dart';
import '../localization/app_strings.dart';

class AppController extends ChangeNotifier {
  AppController(this.repository, this.preferences);

  static const supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
    Locale('en'),
  ];
  final MaydanRepository repository;
  final SharedPreferences preferences;
  Locale _locale = const Locale('ar');
  Locale get locale => _locale;
  AppStrings get strings => AppStrings(_locale.languageCode);
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  String _currency = 'TND';
  String get currency => _currency;

  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> visits = [];
  List<Map<String, dynamic>> employees = [];

  Future<void> initialize() async {
    final manual = preferences.getString('manual_locale');
    final device = PlatformDispatcher.instance.locale.languageCode;
    final initial =
        manual ?? (['ar', 'fr', 'en'].contains(device) ? device : 'en');
    _locale = Locale(initial);
    final theme = preferences.getString('theme_mode') ?? 'system';
    _themeMode = theme == 'light'
        ? ThemeMode.light
        : theme == 'dark'
        ? ThemeMode.dark
        : ThemeMode.system;
    _currency = preferences.getString('currency') ?? 'TND';
    await refresh();
  }

  Future<void> refresh() async {
    projects = await repository.list('projects');
    transactions = await repository.list('transactions');
    visits = await repository.list('visits');
    employees = await repository.list('employees');
    notifyListeners();
  }

  Future<void> setManualLocale(String? code) async {
    if (code == null) {
      await preferences.remove('manual_locale');
      final device = PlatformDispatcher.instance.locale.languageCode;
      _locale = Locale(['ar', 'fr', 'en'].contains(device) ? device : 'en');
    } else {
      await preferences.setString('manual_locale', code);
      _locale = Locale(code);
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await preferences.setString(
      'theme_mode',
      mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
          ? 'dark'
          : 'system',
    );
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    _currency = value.trim().toUpperCase();
    await preferences.setString('currency', _currency);
    notifyListeners();
  }
}
