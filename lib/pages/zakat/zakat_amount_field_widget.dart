import 'package:deenly/components/rupiah_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZakatAmountField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? prefixText;
  final String? suffixText;
  final bool allowDecimal;
  final List<TextInputFormatter> inputFormatters;

  /// A Rupiah amount, regrouped with thousand separators while typing.
  const ZakatAmountField.currency({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
  }) : prefixText = 'Rp ',
       suffixText = null,
       allowDecimal = false,
       inputFormatters = const [RupiahInputFormatter()];

  /// A plain count, e.g. the number of people.
  ZakatAmountField.count({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
  }) : prefixText = null,
       suffixText = null,
       allowDecimal = false,
       inputFormatters = [
         FilteringTextInputFormatter.digitsOnly,
         LengthLimitingTextInputFormatter(3),
       ];

  /// A weight with up to two decimals, using either "." or ",".
  ZakatAmountField.weight({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.suffixText,
  }) : prefixText = null,
       allowDecimal = true,
       inputFormatters = [
         FilteringTextInputFormatter.allow(RegExp(r'^\d{0,7}([.,]\d{0,2})?')),
       ];

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: inputFormatters,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        suffixText: suffixText,
      ),
    );
  }
}
