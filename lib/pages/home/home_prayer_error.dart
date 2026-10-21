import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class HomePrayerError extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onChooseCity;

  const HomePrayerError({
    super.key,
    required this.onRetry,
    required this.onChooseCity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onCard = colorScheme.onPrimary;
    final l10n = AppLocalizations.of(context);

    /// Sits on the prayer gradient of the home overview card, so it uses
    /// the card's light-on-primary colors instead of the error palette.
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 40,
            color: colorScheme.secondaryFixedDim,
          ),
          const SizedBox(height: 12),
          Text(
            l10n?.prayerLoadFailed ?? '',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: onCard),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: onCard,
                  foregroundColor: colorScheme.primary,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n?.retry ?? ''),
              ),
              OutlinedButton.icon(
                onPressed: onChooseCity,
                style: OutlinedButton.styleFrom(
                  foregroundColor: onCard,
                  side: BorderSide(color: onCard.withValues(alpha: 0.6)),
                ),
                icon: const Icon(Icons.location_city_rounded),
                label: Text(l10n?.chooseCity ?? ''),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
