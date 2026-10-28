import 'package:intl/intl.dart';

/// Rupiah is always written the Indonesian way (Rp 1.250.000), whatever
/// the app language, since that is how the amounts appear on payslips
/// and bank statements.
class RupiahFormat {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final NumberFormat _number = NumberFormat.decimalPattern('id');

  static String currency(num value) => _currency.format(value.round());

  static String number(num value) => _number.format(value);

  static double parse(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? 0 : double.parse(digits);
  }

  /// Accepts both "1.5" and "1,5" as decimals.
  static double parseDecimal(String text) {
    return double.tryParse(text.replaceAll(',', '.')) ?? 0;
  }
}
