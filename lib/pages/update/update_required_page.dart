import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shown instead of the app when its version is below the minimum in the
/// app config. It cannot be dismissed; the only way on is to update.
class UpdateRequiredPage extends StatelessWidget {
  final String updateUrl;

  const UpdateRequiredPage({super.key, required this.updateUrl});

  Future<void> _openUpdatePage(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final failedMessage =
        AppLocalizations.of(context)?.updateRequiredOpenFailed ?? '';
    bool opened;
    try {
      opened = await launchUrl(
        Uri.parse(updateUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Opening update page failed: $e');
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(failedMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.system_update_rounded,
                      size: 40,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n?.updateRequiredTitle ?? '',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.updateRequiredMessage ?? '',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _openUpdatePage(context),
                      child: Text(l10n?.updateRequiredButton ?? ''),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
