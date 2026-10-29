import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ZakatGuideError extends StatelessWidget {
  final VoidCallback onRetry;

  const ZakatGuideError({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n?.zakatGuideLoadFailed ?? '',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(l10n?.retry ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
