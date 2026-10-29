import 'package:deenly/components/zakat_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/zakat/zakat_disclaimer_widget.dart';
import 'package:deenly/pages/zakat/zakat_fidyah_page.dart';
import 'package:deenly/pages/zakat/zakat_fitrah_page.dart';
import 'package:deenly/pages/zakat/zakat_gold_page.dart';
import 'package:deenly/pages/zakat/zakat_income_page.dart';
import 'package:deenly/pages/zakat/zakat_maal_page.dart';
import 'package:deenly/pages/zakat/zakat_nisab_card_widget.dart';
import 'package:deenly/pages/zakat/zakat_trade_page.dart';
import 'package:deenly/pages/zakat/zakat_type_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

/// Today's nisab and the list of zakat calculators. Built to be pushed
/// from the home menu, which supplies the app bar.
class ZakatPage extends StatefulWidget {
  const ZakatPage({super.key});

  @override
  State<ZakatPage> createState() => _ZakatPageState();
}

class _ZakatPageState extends State<ZakatPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<ZakatProvider>().load();
    });
  }

  void _open(WidgetBuilder builder) {
    Navigator.push(context, MaterialPageRoute(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () => context.read<ZakatProvider>().load(force: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const ZakatNisabCard(),
          const SizedBox(height: 24),
          Text(
            l10n?.zakatCalculators ?? '',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ZakatTypeCard(
            icon: FontAwesomeIcons.bowlRice,
            title: l10n?.zakatFitrah ?? '',
            description: l10n?.zakatFitrahDesc ?? '',
            onTap: () => _open((_) => const ZakatFitrahPage()),
          ),
          const SizedBox(height: 12),
          ZakatTypeCard(
            icon: FontAwesomeIcons.briefcase,
            title: l10n?.zakatIncome ?? '',
            description: l10n?.zakatIncomeDesc ?? '',
            onTap: () => _open((_) => const ZakatIncomePage()),
          ),
          const SizedBox(height: 12),
          ZakatTypeCard(
            icon: FontAwesomeIcons.piggyBank,
            title: l10n?.zakatMaal ?? '',
            description: l10n?.zakatMaalDesc ?? '',
            onTap: () => _open((_) => const ZakatMaalPage()),
          ),
          const SizedBox(height: 12),
          ZakatTypeCard(
            icon: FontAwesomeIcons.coins,
            title: l10n?.zakatGoldSilver ?? '',
            description: l10n?.zakatGoldSilverDesc ?? '',
            onTap: () => _open((_) => const ZakatGoldPage()),
          ),
          const SizedBox(height: 12),
          ZakatTypeCard(
            icon: FontAwesomeIcons.store,
            title: l10n?.zakatTrade ?? '',
            description: l10n?.zakatTradeDesc ?? '',
            onTap: () => _open((_) => const ZakatTradePage()),
          ),
          const SizedBox(height: 12),
          ZakatTypeCard(
            icon: FontAwesomeIcons.handHoldingHeart,
            title: l10n?.zakatFidyah ?? '',
            description: l10n?.zakatFidyahDesc ?? '',
            onTap: () => _open((_) => const ZakatFidyahPage()),
          ),
          const SizedBox(height: 24),
          const ZakatDisclaimer(),
        ],
      ),
    );
  }
}
