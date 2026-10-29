import 'package:deenly/components/rupiah_format.dart';
import 'package:deenly/components/zakat_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/zakat/zakat_amount_field_widget.dart';
import 'package:deenly/pages/zakat/zakat_calculator_scaffold.dart';
import 'package:deenly/pages/zakat/zakat_fill_hint_widget.dart';
import 'package:deenly/pages/zakat/zakat_haul_switch_widget.dart';
import 'package:deenly/pages/zakat/zakat_nisab_result_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Gold and silver each have their own nisab (85 g and 595 g), so they
/// are calculated and shown separately. Prices per gram are prefilled
/// with the spot price and can be changed to the local price.
class ZakatGoldPage extends StatefulWidget {
  const ZakatGoldPage({super.key});

  @override
  State<ZakatGoldPage> createState() => _ZakatGoldPageState();
}

class _ZakatGoldPageState extends State<ZakatGoldPage> {
  final TextEditingController _gold = TextEditingController();
  final TextEditingController _silver = TextEditingController();
  final TextEditingController _goldPrice = TextEditingController();
  final TextEditingController _silverPrice = TextEditingController();
  bool _haul = true;
  bool _isPriceFilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fillPrices();
  }

  /// Fills the price fields once, as soon as a price is available, without
  /// overwriting what the user has typed.
  void _fillPrices() {
    if (_isPriceFilled) return;
    final price = context.read<ZakatProvider>().price;
    if (price == null) return;
    _isPriceFilled = true;
    if (_goldPrice.text.isEmpty) {
      _goldPrice.text = RupiahFormat.number(price.goldPerGram.round());
    }
    if (_silverPrice.text.isEmpty) {
      _silverPrice.text = RupiahFormat.number(price.silverPerGram.round());
    }
  }

  @override
  void dispose() {
    _gold.dispose();
    _silver.dispose();
    _goldPrice.dispose();
    _silverPrice.dispose();
    super.dispose();
  }

  void _onChanged(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ZakatProvider>();
    final String? priceNote;
    if (provider.isDefaultPrice) {
      priceNote = l10n?.zakatPriceDefault;
    } else if (provider.isStale) {
      priceNote = l10n?.zakatPriceStale;
    } else {
      priceNote = null;
    }
    final gramSuffix = l10n?.zakatGramSuffix ?? '';
    final goldResult = provider.calculateGold(
      RupiahFormat.parseDecimal(_gold.text),
      pricePerGram: RupiahFormat.parse(_goldPrice.text),
      haul: _haul,
    );
    final silverResult = provider.calculateSilver(
      RupiahFormat.parseDecimal(_silver.text),
      pricePerGram: RupiahFormat.parse(_silverPrice.text),
      haul: _haul,
    );
    final totalLabel = l10n?.zakatTotalWealth ?? '';

    final Widget result;
    if (goldResult == null && silverResult == null) {
      result = const ZakatFillHint();
    } else {
      result = Column(
        children: [
          if (goldResult != null)
            ZakatNisabResult(
              title: l10n?.zakatGold,
              result: goldResult,
              baseLabel: totalLabel,
            ),
          if (goldResult != null && silverResult != null)
            const SizedBox(height: 12),
          if (silverResult != null)
            ZakatNisabResult(
              title: l10n?.zakatSilver,
              result: silverResult,
              baseLabel: totalLabel,
            ),
        ],
      );
    }

    return ZakatCalculatorScaffold(
      title: l10n?.zakatGoldSilver ?? '',
      inputs: [
        ZakatAmountField.weight(
          label: l10n?.zakatGoldGrams ?? '',
          controller: _gold,
          onChanged: _onChanged,
          suffixText: gramSuffix,
        ),
        ZakatAmountField.currency(
          label: l10n?.zakatGoldPricePerGram ?? '',
          controller: _goldPrice,
          onChanged: _onChanged,
        ),
        ZakatAmountField.weight(
          label: l10n?.zakatSilverGrams ?? '',
          controller: _silver,
          onChanged: _onChanged,
          suffixText: gramSuffix,
        ),
        ZakatAmountField.currency(
          label: l10n?.zakatSilverPricePerGram ?? '',
          controller: _silverPrice,
          onChanged: _onChanged,
        ),
        Text(
          [l10n?.zakatMetalPriceNote ?? '', ?priceNote].join('\n'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        ZakatHaulSwitch(
          value: _haul,
          onChanged: (value) => setState(() => _haul = value),
        ),
      ],
      result: result,
    );
  }
}
