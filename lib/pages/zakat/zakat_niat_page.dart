import 'package:deenly/components/app_theme.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/zakat_niat_model.dart';
import 'package:deenly/pages/zakat/zakat_load_error_widget.dart';
import 'package:deenly/pages/zakat/zakat_niat_item_widget.dart';
import 'package:deenly/pages/zakat/zakat_source_link_widget.dart';
import 'package:deenly/proxys/zakat_niat_proxy.dart';
import 'package:flutter/material.dart';

/// Zakat intentions and the prayer for receiving zakat, grouped under a
/// heading per group in the order of the bundled file.
class ZakatNiatPage extends StatefulWidget {
  const ZakatNiatPage({super.key});

  @override
  State<ZakatNiatPage> createState() => _ZakatNiatPageState();
}

class _ZakatNiatPageState extends State<ZakatNiatPage> {
  final ZakatNiatProxy _proxy = ZakatNiatProxy();
  ZakatNiatListModel? _niats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNiats();
  }

  Future<void> _loadNiats() async {
    setState(() => _isLoading = true);
    ZakatNiatListModel? niats;
    try {
      niats = await _proxy.getNiats();
    } catch (e, st) {
      debugPrint('Loading zakat niats failed: $e\n$st');
    }

    if (!mounted) return;
    setState(() {
      _niats = niats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final niats = _niats;

    final Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (niats == null || niats.items.isEmpty) {
      body = ZakatLoadError(
        message: l10n?.zakatNiatLoadFailed ?? '',
        onRetry: _loadNiats,
      );
    } else {
      body = _NiatList(niats: niats);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.zakatNiat ?? '',
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

class _NiatList extends StatelessWidget {
  final ZakatNiatListModel niats;

  const _NiatList({required this.niats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final languageCode = Localizations.localeOf(context).languageCode;
    final divider = Divider(
      height: 1,
      indent: 20,
      endIndent: 20,
      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
    );

    final children = <Widget>[];
    String? currentGroup;
    for (final niat in niats.items) {
      final group = niat.group.of(languageCode);
      if (group != currentGroup) {
        currentGroup = group;
        children.add(
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            color: colorScheme.surfaceContainerLow,
            child: Text(
              group,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        );
      } else {
        children.add(divider);
      }
      children.add(ZakatNiatItem(niat: niat, languageCode: languageCode));
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        ...children,
        const SizedBox(height: 8),
        for (final source in niats.sources)
          ZakatSourceLink(name: source.name, url: source.url),
      ],
    );
  }
}
