import 'package:deenly/components/rupiah_format.dart';
import 'package:deenly/components/zakat_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/zakat/zakat_amount_field_widget.dart';
import 'package:deenly/pages/zakat/zakat_calculator_scaffold.dart';
import 'package:deenly/pages/zakat/zakat_fill_hint_widget.dart';
import 'package:deenly/pages/zakat/zakat_result_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Fidyah is paid for each fasting day that cannot be made up, e.g. by
/// the elderly or the chronically ill, at a fixed amount per day.
class ZakatFidyahPage extends StatefulWidget {
  const ZakatFidyahPage({super.key});

  @override
  State<ZakatFidyahPage> createState() => _ZakatFidyahPageState();
}

class _ZakatFidyahPageState extends State<ZakatFidyahPage> {
  final TextEditingController _days = TextEditingController();
  final TextEditingController _perDay = TextEditingController();

  @override
  void initState() {
    super.initState();
    final perDay = context.read<ZakatProvider>().fidyahPerDay;
    if (perDay > 0) _perDay.text = RupiahFormat.number(perDay);
  }

  @override
  void dispose() {
    _days.dispose();
    _perDay.dispose();
    super.dispose();
  }

  void _onChanged(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ZakatProvider>();
    final decree = provider.fitrahDecree;
    final days = int.tryParse(_days.text) ?? 0;
    final perDay = RupiahFormat.parse(_perDay.text);
    final total = provider.calculateFidyah(days, perDay: perDay);

    return ZakatCalculatorScaffold(
      title: l10n?.zakatFidyah ?? '',
      inputs: [
        ZakatAmountField.count(
          label: l10n?.zakatFidyahDays ?? '',
          controller: _days,
          onChanged: _onChanged,
        ),
        ZakatAmountField.currency(
          label: l10n?.zakatFidyahPerDay ?? '',
          controller: _perDay,
          onChanged: _onChanged,
        ),
        if (l10n != null && decree != null)
          Text(
            l10n.zakatFidyahNote(
              l10n.zakatDecree('${decree.number}', '${decree.year}'),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
      result: l10n == null || total <= 0
          ? const ZakatFillHint()
          : ZakatResultCard(
              title: l10n.zakatResult,
              amountLabel: l10n.zakatFidyahAmount,
              amount: RupiahFormat.currency(total),
              formula: l10n.zakatDaysTimes(days, RupiahFormat.currency(perDay)),
            ),
    );
  }
}
