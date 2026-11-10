import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expensex/features/settings/providers/settings_provider.dart';

class CurrencyHelper {
  const CurrencyHelper._();

  static String symbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'BDT':
      default:
        return '৳';
    }
  }

  static String format(double amount, String currencyCode) {
    final sym = symbol(currencyCode);
    return '$sym ${amount.toStringAsFixed(2)}';
  }
}

extension CurrencyExtension on BuildContext {
  String currency(double amount) {
    final code = watch<SettingsProvider>().currency;
    return CurrencyHelper.format(amount, code);
  }

  String get currencySymbol {
    final code = watch<SettingsProvider>().currency;
    return CurrencyHelper.symbol(code);
  }
}
