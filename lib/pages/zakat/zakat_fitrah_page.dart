import 'package:deenly/components/rupiah_format.dart';
import 'package:deenly/components/zakat_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/zakat_result_model.dart';
import 'package:deenly/pages/zakat/zakat_amount_field_widget.dart';
import 'package:deenly/pages/zakat/zakat_calculator_scaffold.dart';
import 'package:deenly/pages/zakat/zakat_fill_hint_widget.dart';
import 'package:deenly/pages/zakat/zakat_result_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Zakat fitrah has no nisab: it is 2.5 kg (or 3.5 liters) of rice per
/// person, or its value in money.
class ZakatFitrahPage extends StatefulWidget {
  const ZakatFitrahPage({super.key});

  @override
  State<ZakatFitrahPage> createState() => _ZakatFitrahPageState();
}

class _ZakatFitrahPageState extends State<ZakatFitrahPage> {
  final TextEditingController _people = TextEditingController(text: '1');
  final TextEditingController _perPerson = TextEditingController();
  bool _payWithRice = true;
  bool _inLiters = false;

  @override
  void initState() {
    super.initState();
    final perPerson = context.read<ZakatProvider>().fitrahPerPerson;
    if (perPerson > 0) _perPerson.text = RupiahFormat.number(perPerson);
  }

  @override
  void dispose() {
    _people.dispose();
    _perPerson.dispose();
    super.dispose();
  }

  void _onChanged(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final decree = context.watch<ZakatProvider>().fitrahDecree;

    return ZakatCalculatorScaffold(
      title: l10n?.zakatFitrah ?? '',
      inputs: [
        ZakatAmountField.count(
          label: l10n?.zakatPeople ?? '',
          controller: _people,
          onChanged: _onChanged,
        ),
        _ChoiceSelector(
          label: l10n?.zakatPayWith ?? '',
          firstLabel: l10n?.zakatRice ?? '',
          secondLabel: l10n?.zakatMoney ?? '',
          isFirst: _payWithRice,
          onChanged: (value) => setState(() => _payWithRice = value),
        ),
        if (_payWithRice)
          _ChoiceSelector(
            label: l10n?.zakatRiceUnit ?? '',
            firstLabel: l10n?.zakatKilogram ?? '',
            secondLabel: l10n?.zakatLiterUnit ?? '',
            isFirst: !_inLiters,
            onChanged: (value) => setState(() => _inLiters = !value),
          ),
        if (!_payWithRice) ...[
          ZakatAmountField.currency(
            label: l10n?.zakatFitrahPerPerson ?? '',
            controller: _perPerson,
            onChanged: _onChanged,
          ),
          if (l10n != null && decree != null)
            Text(
              l10n.zakatFitrahNote(
                l10n.zakatDecree('${decree.number}', '${decree.year}'),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ],
      result: _FitrahResult(
        people: int.tryParse(_people.text) ?? 0,
        payWithRice: _payWithRice,
        inLiters: _inLiters,
        perPerson: RupiahFormat.parse(_perPerson.text),
      ),
    );
  }
}

class _FitrahResult extends StatelessWidget {
  final int people;
  final bool payWithRice;
  final bool inLiters;
  final double perPerson;

  const _FitrahResult({
    required this.people,
    required this.payWithRice,
    required this.inLiters,
    required this.perPerson,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null || people <= 0) return const ZakatFillHint();

    final String amount;
    final String formula;
    if (payWithRice) {
      final languageCode = Localizations.localeOf(context).languageCode;
      final number = NumberFormat.decimalPattern(languageCode);
      final perPerson = inLiters
          ? ZakatProvider.riceLitersPerPerson
          : ZakatProvider.riceKgPerPerson;
      final unit = inLiters ? l10n.zakatLiter : l10n.zakatKg;
      amount = unit(number.format(people * perPerson));
      formula = l10n.zakatPeopleTimes(people, unit(number.format(perPerson)));
    } else {
      if (perPerson <= 0) return const ZakatFillHint();
      amount = RupiahFormat.currency(people * perPerson);
      formula = l10n.zakatPeopleTimes(people, RupiahFormat.currency(perPerson));
    }

    return ZakatResultCard(
      status: ZakatStatus.obligatory,
      amount: amount,
      formula: formula,
    );
  }
}

/// Two-option segmented button with a [label] above it; [isFirst] is
/// true when the first option is selected.
class _ChoiceSelector extends StatelessWidget {
  final String label;
  final String firstLabel;
  final String secondLabel;
  final bool isFirst;
  final ValueChanged<bool> onChanged;

  const _ChoiceSelector({
    required this.label,
    required this.firstLabel,
    required this.secondLabel,
    required this.isFirst,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: true, label: Text(firstLabel)),
              ButtonSegment(value: false, label: Text(secondLabel)),
            ],
            selected: {isFirst},
            onSelectionChanged: (selection) => onChanged(selection.first),
          ),
        ),
      ],
    );
  }
}
