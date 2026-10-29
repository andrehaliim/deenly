import 'package:deenly/components/app_theme.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/zakat_guide_model.dart';
import 'package:deenly/pages/zakat/zakat_guide_section_widget.dart';
import 'package:deenly/pages/zakat/zakat_load_error_widget.dart';
import 'package:deenly/pages/zakat/zakat_source_link_widget.dart';
import 'package:deenly/proxys/zakat_guide_proxy.dart';
import 'package:flutter/material.dart';

/// Basic zakat knowledge (meaning, conditions, when to pay zakat al-fitr
/// and recipients) read from the bundled guide, ending with links to its
/// sources.
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
      body = ZakatLoadError(
        message: l10n?.zakatGuideLoadFailed ?? '',
        onRetry: _loadGuide,
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          for (final section in guide.sections) ...[
            ZakatGuideSection(section: section, languageCode: languageCode),
            const SizedBox(height: 16),
          ],
          for (final source in guide.sources)
            ZakatSourceLink(name: source.name, url: source.url),
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
