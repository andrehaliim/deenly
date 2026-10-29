import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Source: [name]" link that opens [url] in the browser, placed at the
/// end of pages whose content is taken from an outside source.
class ZakatSourceLink extends StatelessWidget {
  final String name;
  final String url;

  const ZakatSourceLink({super.key, required this.name, required this.url});

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final failedMessage = AppLocalizations.of(context)?.couldNotOpenLink ?? '';
    bool opened;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      opened = false;
    }

    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(failedMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: TextButton.icon(
        onPressed: () => _open(context),
        icon: const Icon(Icons.open_in_new_rounded, size: 16),
        label: Text(
          l10n?.zakatGuideSource(name) ?? name,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
