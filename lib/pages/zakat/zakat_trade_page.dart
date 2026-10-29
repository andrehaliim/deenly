import 'package:deenly/components/rupiah_format.dart';
import 'package:deenly/components/zakat_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/zakat/zakat_amount_field_widget.dart';
import 'package:deenly/pages/zakat/zakat_calculator_scaffold.dart';
import 'package:deenly/pages/zakat/zakat_haul_switch_widget.dart';
import 'package:deenly/pages/zakat/zakat_nisab_result_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ZakatTradePage extends StatefulWidget {
  const ZakatTradePage({super.key});

  @override
  State<ZakatTradePage> createState() => _ZakatTradePageState();
}

class _ZakatTradePageState extends State<ZakatTradePage> {
  final TextEditingController _capital = TextEditingController();
  final TextEditingController _profit = TextEditingController();
  final TextEditingController _receivables = TextEditingController();
  final TextEditingController _debts = TextEditingController();
  bool _haul = true;

  @override
  void dispose() {
    _capital.dispose();
    _profit.dispose();
    _receivables.dispose();
    _debts.dispose();
    super.dispose();
  }

  void _onChanged(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ZakatProvider>();
    final assets =
        RupiahFormat.parse(_capital.text) +
        RupiahFormat.parse(_profit.text) +
        RupiahFormat.parse(_receivables.text);

    return ZakatCalculatorScaffold(
      title: l10n?.zakatTrade ?? '',
      inputs: [
        ZakatAmountField.currency(
          label: l10n?.zakatTradeCapital ?? '',
          controller: _capital,
          onChanged: _onChanged,
        ),
        ZakatAmountField.currency(
          label: l10n?.zakatTradeProfit ?? '',
          controller: _profit,
          onChanged: _onChanged,
        ),
        ZakatAmountField.currency(
          label: l10n?.zakatTradeReceivables ?? '',
          controller: _receivables,
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
        result: provider.calculateTrade(
          assets: assets,
          debts: RupiahFormat.parse(_debts.text),
          haul: _haul,
        ),
        baseLabel: l10n?.zakatTotalTradeAssets ?? '',
      ),
    );
  }
}
