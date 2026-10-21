import 'package:deenly/components/app_theme.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/doa_model.dart';
import 'package:deenly/pages/doa/doa_error_widget.dart';
import 'package:deenly/pages/doa/doa_item_widget.dart';
import 'package:deenly/proxys/doa_proxy.dart';
import 'package:flutter/material.dart';

/// Lists every doa of one category as plain rows separated by dividers.
class DoaDetailPage extends StatefulWidget {
  final DoaGroupModel group;

  const DoaDetailPage({super.key, required this.group});

  @override
  State<DoaDetailPage> createState() => _DoaDetailPageState();
}

class _DoaDetailPageState extends State<DoaDetailPage> {
  final DoaProxy _proxy = DoaProxy();
  List<DoaModel>? _doas;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoas();
  }

  Future<void> _loadDoas() async {
    setState(() => _isLoading = true);
    List<DoaModel>? doas;
    try {
      doas = await _proxy.getDoasByGroup(widget.group.id);
    } catch (e, st) {
      debugPrint('Loading doas failed: $e\n$st');
    }

    if (!mounted) return;
    setState(() {
      _doas = doas;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final doas = _doas;

    final Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (doas == null || doas.isEmpty) {
      body = DoaError(onRetry: _loadDoas);
    } else {
      body = _DoaList(doas: doas);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.menuDoa ?? '',
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

class _DoaList extends StatelessWidget {
  final List<DoaModel> doas;

  const _DoaList({required this.doas});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final dividerColor = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.6);

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: doas.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, indent: 20, endIndent: 20, color: dividerColor),
      itemBuilder: (context, index) => DoaItem(
        doa: doas[index],
        number: index + 1,
        languageCode: languageCode,
      ),
    );
  }
}
