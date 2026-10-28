import 'package:deenly/components/rupiah_format.dart';
import 'package:deenly/components/zakat_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/zakat/zakat_amount_field_widget.dart';
import 'package:deenly/pages/zakat/zakat_calculator_scaffold.dart';
import 'package:deenly/pages/zakat/zakat_haul_switch_widget.dart';
import 'package:deenly/pages/zakat/zakat_nisab_result_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ZakatMaalPage extends StatefulWidget {
  const ZakatMaalPage({super.key});

  @override
  State<ZakatMaalPage> createState() => _ZakatMaalPageState();
}

class _ZakatMaalPageState extends State<ZakatMaalPage> {
  final TextEditingController _savings = TextEditingController();
  final TextEditingController _deposits = TextEditingController();
  final TextEditingController _investments = TextEditingController();
  final TextEditingController _debts = TextEditingController();
  bool _haul = true;

  @override
  void dispose() {
    _savings.dispose();
    _deposits.dispose();
    _investments.dispose();
    _debts.dispose();
    super.dispose();
  }

  void _onChanged(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ZakatProvider>();
    final assets =
        RupiahFormat.parse(_savings.text) +
        RupiahFormat.parse(_deposits.text) +
        RupiahFormat.parse(_investments.text);

    return ZakatCalculatorScaffold(
      title: l10n?.zakatMaal ?? '',
      inputs: [
        ZakatAmountField.currency(
          label: l10n?.zakatSavings ?? '',
          controller: _savings,
          onChanged: _onChanged,
        ),
        ZakatAmountField.currency(
          label: l10n?.zakatDeposits ?? '',
          controller: _deposits,
          onChanged: _onChanged,
        ),
        ZakatAmountField.currency(
          label: l10n?.zakatInvestments ?? '',
          controller: _investments,
          onChanged: _onChanged,
        ),
        ZakatAmountField.currency(
          label: l10n?.zakatDebts ?? '',
          controller: _debts,
          onChanged: _onChanged,
        ),
        ZakatHaulSwitch(
          value: _haul,
          onChanged: (value) => setState(() => _haul = value),
        ),
      ],
      result: ZakatNisabResult(
        result: provider.calculateMaal(
          assets: assets,
          debts: RupiahFormat.parse(_debts.text),
          haul: _haul,
        ),
        baseLabel: l10n?.zakatTotalWealth ?? '',
      ),
    );
  }
}
