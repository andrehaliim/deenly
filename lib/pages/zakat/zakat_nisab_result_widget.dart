import 'package:deenly/components/rupiah_format.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/zakat_result_model.dart';
import 'package:deenly/pages/zakat/zakat_fill_hint_widget.dart';
import 'package:deenly/pages/zakat/zakat_result_card_widget.dart';
import 'package:flutter/material.dart';

/// Shows a nisab-based [result] as a result card, or the fill hint when
/// there is nothing to calculate yet.
class ZakatNisabResult extends StatelessWidget {
  final ZakatResultModel? result;
  final String baseLabel;
  final String? title;

  const ZakatNisabResult({
    super.key,
    required this.result,
    required this.baseLabel,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final result = this.result;
    if (result == null) return const ZakatFillHint();

    final l10n = AppLocalizations.of(context);
    final base = RupiahFormat.currency(result.base);

    return ZakatResultCard(
      title: title,
      status: result.status,
      amount: RupiahFormat.currency(result.amount),
      formula: l10n?.zakatRateFormula(base) ?? '',
      rows: [
        (baseLabel, base),
        (l10n?.zakatNisab ?? '', RupiahFormat.currency(result.nisab)),
      ],
    );
  }
}
