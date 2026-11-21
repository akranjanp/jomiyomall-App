import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _compactFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(num? amount) {
    if (amount == null) return '₹0';
    if (amount % 1 == 0) {
      return _compactFormat.format(amount);
    }
    return _indianFormat.format(amount);
  }

  static String formatFromString(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) return '₹0';
    final cleanStr = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.tryParse(cleanStr) ?? 0.0;
    return format(amount);
  }
}
