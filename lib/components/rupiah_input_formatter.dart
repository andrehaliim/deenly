import 'package:deenly/components/rupiah_format.dart';
import 'package:flutter/services.dart';

/// Keeps only digits and regroups them with thousand separators while
/// typing, e.g. "1500000" becomes "1.500.000".
class RupiahInputFormatter extends TextInputFormatter {
  static const int _maxDigits = 15;

  const RupiahInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    if (digits.length > _maxDigits) return oldValue;

    final formatted = RupiahFormat.number(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
