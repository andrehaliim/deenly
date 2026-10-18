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
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.prayerLoadFailed ?? '',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n?.retry ?? ''),
                ),
                OutlinedButton.icon(
                  onPressed: onChooseCity,
                  icon: const Icon(Icons.location_city_rounded),
                  label: Text(l10n?.chooseCity ?? ''),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
