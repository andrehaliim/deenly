import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/zakat/zakat_guide_page.dart';
import 'package:flutter/material.dart';

/// App bar action of the zakat menu that opens the zakat guide.
class ZakatGuideButton extends StatelessWidget {
  const ZakatGuideButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context)?.zakatGuide,
      icon: Icon(
        Icons.info_outline_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ZakatGuidePage()),
      ),
    );
  }
}
