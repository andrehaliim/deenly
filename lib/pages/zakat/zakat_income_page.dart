import 'package:deenly/components/rupiah_format.dart';
import 'package:deenly/components/zakat_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/zakat/zakat_amount_field_widget.dart';
import 'package:deenly/pages/zakat/zakat_calculator_scaffold.dart';
import 'package:deenly/pages/zakat/zakat_nisab_result_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ZakatIncomePage extends StatefulWidget {
  const ZakatIncomePage({super.key});

  @override
  State<ZakatIncomePage> createState() => _ZakatIncomePageState();
}

class _ZakatIncomePageState extends State<ZakatIncomePage> {
  final TextEditingController _income = TextEditingController();
  final TextEditingController _otherIncome = TextEditingController();

  @override
  void dispose() {
    _income.dispose();
    _otherIncome.dispose();
    super.dispose();
  }

  void _onChanged(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ZakatProvider>();
    final nisab = provider.nisab;
    final total =
        RupiahFormat.parse(_income.text) +
        RupiahFormat.parse(_otherIncome.text);

    return ZakatCalculatorScaffold(
      title: l10n?.zakatIncome ?? '',
      inputs: [
        ZakatAmountField.currency(
          label: l10n?.zakatMonthlyIncome ?? '',
          controller: _income,
          onChanged: _onChanged,
        ),
        ZakatAmountField.currency(
          label: l10n?.zakatOtherIncome ?? '',
          controller: _otherIncome,
          onChanged: _onChanged,
        ),
        if (nisab != null)
          Text(
            l10n?.zakatIncomeNisabNote(RupiahFormat.currency(nisab / 12)) ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
      result: ZakatNisabResult(
        result: provider.calculateIncome(total),
        baseLabel: l10n?.zakatTotalIncome ?? '',
      ),
    );
  }
}
