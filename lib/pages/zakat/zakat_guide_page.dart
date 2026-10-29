import 'package:deenly/components/app_theme.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/zakat_guide_model.dart';
import 'package:deenly/pages/zakat/zakat_guide_error_widget.dart';
import 'package:deenly/pages/zakat/zakat_guide_section_widget.dart';
import 'package:deenly/proxys/zakat_guide_proxy.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Basic zakat knowledge (meaning, conditions and recipients) read from
/// the bundled guide, ending with a link to its source.
class ZakatGuidePage extends StatefulWidget {
  const ZakatGuidePage({super.key});

  @override
  State<ZakatGuidePage> createState() => _ZakatGuidePageState();
}

class _ZakatGuidePageState extends State<ZakatGuidePage> {
  final ZakatGuideProxy _proxy = ZakatGuideProxy();
  ZakatGuideModel? _guide;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuide();
  }

  Future<void> _loadGuide() async {
    setState(() => _isLoading = true);
    ZakatGuideModel? guide;
    try {
      guide = await _proxy.getGuide();
    } catch (e, st) {
      debugPrint('Loading zakat guide failed: $e\n$st');
    }

    if (!mounted) return;
    setState(() {
      _guide = guide;
      _isLoading = false;
    });
  }

  Future<void> _openSource(String url) async {
    bool opened;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      opened = false;
    }

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.couldNotOpenLink ?? ''),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final guide = _guide;

    final Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (guide == null) {
      body = ZakatGuideError(onRetry: _loadGuide);
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          for (final section in guide.sections) ...[
            ZakatGuideSection(section: section, languageCode: languageCode),
            const SizedBox(height: 16),
          ],
          _GuideSource(
            name: guide.sourceName,
            onTap: () => _openSource(guide.sourceUrl),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.zakatGuide ?? '',
          style: theme.extension<AppTextStyles>()?.brandTitle,
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(top: false, child: body),
    );
  }
}

class _GuideSource extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _GuideSource({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.open_in_new_rounded, size: 16),
        label: Text(
          l10n?.zakatGuideSource(name) ?? name,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
