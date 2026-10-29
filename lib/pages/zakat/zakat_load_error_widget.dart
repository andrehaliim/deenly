import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Shown when bundled zakat content (the guide or the niats) fails to
/// load, with a [message] naming what failed.
class ZakatLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ZakatLoadError({
    super.key,
    required this.message,
    required this.onRetry,
  });

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
              message,
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
