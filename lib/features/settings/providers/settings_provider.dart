import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _currencyKey = 'currency';

  String _currency = 'BDT';

  String get currency => _currency;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _currency = prefs.getString(_currencyKey) ?? 'BDT';

    notifyListeners();
  }

  Future<void> changeCurrency(String currency) async {
    _currency = currency;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_currencyKey, currency);

    notifyListeners();
  }
}
