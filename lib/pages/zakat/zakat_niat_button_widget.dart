import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/zakat/zakat_niat_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// App bar action of the zakat menu that opens the zakat niats.
class ZakatNiatButton extends StatelessWidget {
  const ZakatNiatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context)?.zakatNiat,
      icon: FaIcon(
        FontAwesomeIcons.handsPraying,
        size: 18,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ZakatNiatPage()),
      ),
    );
  }
}
