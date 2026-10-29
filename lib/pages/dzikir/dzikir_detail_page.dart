import 'package:deenly/components/app_theme.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/dzikir_category_model.dart';
import 'package:deenly/models/dzikir_model.dart';
import 'package:deenly/pages/dzikir/dzikir_error_widget.dart';
import 'package:deenly/pages/dzikir/dzikir_item_widget.dart';
import 'package:deenly/proxys/dzikir_proxy.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

/// Reads one dzikir category in order. Tapping a card counts one
/// recitation; when a card reaches zero the list scrolls to the next
/// unfinished one.
class DzikirDetailPage extends StatefulWidget {
  final DzikirCategoryModel category;

  const DzikirDetailPage({super.key, required this.category});

  @override
  State<DzikirDetailPage> createState() => _DzikirDetailPageState();
}

class _DzikirDetailPageState extends State<DzikirDetailPage> {
  final DzikirProxy _proxy = DzikirProxy();
  List<DzikirModel>? _dzikirs;
  List<int> _remaining = [];
  List<GlobalKey> _itemKeys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDzikirs();
  }

  Future<void> _loadDzikirs() async {
    setState(() => _isLoading = true);
    List<DzikirModel>? dzikirs;
    try {
      dzikirs = await _proxy.getDzikirsByCategory(widget.category.id);
    } catch (e, st) {
      debugPrint('Loading dzikirs failed: $e\n$st');
    }

    if (!mounted) return;
    setState(() {
      _dzikirs = dzikirs;
      _remaining = [for (final dzikir in dzikirs ?? []) dzikir.count];
      _itemKeys = [for (final _ in _remaining) GlobalKey()];
      _isLoading = false;
    });
  }

  int get _doneCount => _remaining.where((count) => count == 0).length;

  int? get _activeIndex {
    final index = _remaining.indexWhere((count) => count > 0);
    return index == -1 ? null : index;
  }

  void _onCount(int index) {
    if (_remaining[index] == 0) return;
    final isFinished = _remaining[index] == 1;
    setState(() => _remaining[index]--);

    if (!isFinished) {
      _vibrate(50);
      return;
    }

    _vibrate(400);
    final next = _activeIndex;
    if (next == null) {
      _showAllDone();
    } else {
      _scrollTo(next);
    }
  }

  bool get _hasProgress {
    final dzikirs = _dzikirs ?? [];
    for (var i = 0; i < dzikirs.length; i++) {
      if (_remaining[i] < dzikirs[i].count) return true;
    }
    return false;
  }

  void _onReset(int index) {
    final dzikirs = _dzikirs;
    if (dzikirs == null) return;
    setState(() => _remaining[index] = dzikirs[index].count);
    _vibrate(50);
    _showSnackBar(AppLocalizations.of(context)?.dzikirItemReset ?? '');
  }

  void _restart() {
    final dzikirs = _dzikirs;
    if (dzikirs == null) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() {
      _remaining = [for (final dzikir in dzikirs) dzikir.count];
    });
    _scrollTo(0);
  }

  Future<void> _confirmRestart() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.dzikirRestart ?? ''),
        content: Text(l10n?.dzikirRestartConfirm ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? ''),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n?.dzikirRestart ?? ''),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) _restart();
  }

  void _showSnackBar(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  void _vibrate(int duration) async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: duration);
    }
  }

  /// Waits a frame so the finished card has rebuilt before scrolling.
  void _scrollTo(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemContext = _itemKeys[index].currentContext;
      if (itemContext == null) return;
      Scrollable.ensureVisible(
        itemContext,
        alignment: 0.05,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _showAllDone() {
    final l10n = AppLocalizations.of(context);
    _showSnackBar(
      l10n?.dzikirAllDone ?? '',
      action: SnackBarAction(
        label: l10n?.dzikirRestart ?? '',
        onPressed: _restart,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final dzikirs = _dzikirs;

    final Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (dzikirs == null || dzikirs.isEmpty) {
      body = DzikirError(onRetry: _loadDzikirs);
    } else {
      final activeIndex = _activeIndex;
      body = Column(
        children: [
          _ProgressHeader(done: _doneCount, total: dzikirs.length),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: Column(
                children: [
                  for (var i = 0; i < dzikirs.length; i++)
                    Padding(
                      key: _itemKeys[i],
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DzikirItem(
                        dzikir: dzikirs[i],
                        number: i + 1,
                        remaining: _remaining[i],
                        isActive: i == activeIndex,
                        languageCode: languageCode,
                        onTap: () => _onCount(i),
                        onReset: () => _onReset(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.name(languageCode),
          style: theme.extension<AppTextStyles>()?.brandTitle,
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: AppLocalizations.of(context)?.dzikirRestart,
            color: theme.colorScheme.primary,
            onPressed: _hasProgress ? _confirmRestart : null,
          ),
        ],
      ),
      body: SafeArea(top: false, child: body),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int done;
  final int total;

  const _ProgressHeader({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n?.dzikirTapHint ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n?.dzikirProgress(done, total) ?? '',
                style: labelStyle?.copyWith(color: colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: total == 0 ? 0 : done / total),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
