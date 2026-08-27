import 'dart:async';

import 'package:deenly/components/database_helper.dart';
import 'package:deenly/components/surah_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/surah_detail_model.dart';
import 'package:deenly/models/surah_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sqflite/sqflite.dart';

class QuranDetailPage extends StatefulWidget {
  final SurahModel surah;
  final int juzFrom;
  final String code;
  const QuranDetailPage({
    super.key,
    required this.surah,
    required this.juzFrom,
    required this.code,
  });

  @override
  State<QuranDetailPage> createState() => _QuranDetailPageState();
}

class _QuranDetailPageState extends State<QuranDetailPage> {
  late SurahModel _activeSurah;
  bool _isLoadingNextSurah = false;
  bool _isInitialSurah = true;
  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    _activeSurah = widget.surah;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SurahProvider>().getSurahDetail(widget.surah.id);
    });
  }

  Future<void> _goToNextSurah() async {
    if (_isLoadingNextSurah) return;

    final nextId = _activeSurah.id + 1;
    if (nextId > 114) {
      return;
    }

    setState(() {
      _isLoadingNextSurah = true;
    });

    final provider = context.read<SurahProvider>();
    await provider.getSurahDetail(nextId);
    final nextSurah = await provider.getSurahById(nextId);

    if (!mounted) return;

    setState(() {
      _isLoadingNextSurah = false;
      _activeSurah = nextSurah;
      _isInitialSurah = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            setState(() {
              _showOptions = !_showOptions;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _activeSurah.name(widget.code),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Icon(
                _showOptions
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.black,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<SurahProvider>(
          builder: (context, provider, _) {
            if (provider.surahDetail == null && provider.isDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.surahDetail == null) {
              return const Center(child: Text('Failed to fetch surah detail'));
            }

            return Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        final isIncoming =
                            child.key == ValueKey(_activeSurah.id);
                        final offsetAnimation =
                            Tween<Offset>(
                              begin: isIncoming
                                  ? const Offset(0.0, 1.0)
                                  : const Offset(0.0, -1.0),
                              end: const Offset(0.0, 0.0),
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOutCubic,
                              ),
                            );
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                  layoutBuilder:
                      (Widget? currentChild, List<Widget> previousChildren) {
                        return Stack(
                          children: <Widget>[
                            ...previousChildren,
                            (currentChild ?? const SizedBox.shrink()),
                          ],
                        );
                      },
                  child: SurahDetailList(
                    key: ValueKey(_activeSurah.id),
                    surah: _activeSurah,
                    details: provider.surahDetail!,
                    langCode: provider.code ?? 'en',
                    restorePosition: _isInitialSurah,
                    isLoadingNextSurah: _isLoadingNextSurah,
                    onNextSurahTriggered: _goToNextSurah,
                    juzFrom: widget.juzFrom,
                  ),
                ),

                if (_showOptions)
                  SurahOptionsPanel(
                    surah: _activeSurah,
                    onSurahSelected: (surah) async {
                      if (surah.id == _activeSurah.id) {
                        setState(() => _showOptions = false);
                        return;
                      }
                      setState(() {
                        _activeSurah = surah;
                        _isInitialSurah = true;
                        _showOptions = false;
                      });
                      context.read<SurahProvider>().getSurahDetail(surah.id);
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SurahDetailList extends StatefulWidget {
  final SurahModel surah;
  final List<SurahDetailModel> details;
  final String langCode;
  final bool restorePosition;
  final bool isLoadingNextSurah;
  final VoidCallback onNextSurahTriggered;
  final int juzFrom;

  const SurahDetailList({
    super.key,
    required this.surah,
    required this.details,
    required this.langCode,
    required this.restorePosition,
    required this.isLoadingNextSurah,
    required this.onNextSurahTriggered,
    required this.juzFrom,
  });

  @override
  State<SurahDetailList> createState() => _SurahDetailListState();
}

class _SurahDetailListState extends State<SurahDetailList> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  bool _showNextSurahHint = false;
  double _overscrollAtBottom = 0;
  static const double _overscrollTriggerThreshold = 120.0;
  static const int _maxSurahId = 114;
  int? _pendingIndex;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    _addScrollListener();

    if (widget.restorePosition && widget.juzFrom > 0) {
      _loadLastPosition();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _saveLastAyah(_pendingIndex);
    super.dispose();
  }

  void _addScrollListener() async {
    _itemPositionsListener.itemPositions.addListener(() {
      final positions = _itemPositionsListener.itemPositions.value;
      if (positions.isEmpty) return;

      final visibleItems = positions.where((item) => item.itemLeadingEdge >= 0);
      if (visibleItems.isEmpty) return;

      final firstVisible = visibleItems.reduce(
        (min, item) => item.itemLeadingEdge < min.itemLeadingEdge ? item : min,
      );

      _pendingIndex = firstVisible.index;

      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 600), () {
        _saveLastAyah(_pendingIndex);
      });
    });
  }

  Future<void> _saveLastAyah(int? index) async {
    if (index == null) return;
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      DatabaseHelper.tableContinueReading,
      {
        'surah_id': widget.surah.id,
        'ayah_number': index,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void _loadLastPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warmUpAndJump();
    });
  }

  Future<void> _warmUpAndJump() async {
    if (!_itemScrollController.isAttached) {
      await Future.delayed(const Duration(milliseconds: 50));
      return _warmUpAndJump();
    }

    _itemScrollController.jumpTo(index: widget.juzFrom);

    await Future.delayed(const Duration(milliseconds: 100));

    if (_itemScrollController.isAttached) {
      _itemScrollController.jumpTo(index: widget.juzFrom);
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final totalItems = widget.details.length + 2;
    final lastItemIndex = totalItems - 1;

    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return false;

    final lastItem = positions.cast<ItemPosition?>().firstWhere(
      (pos) => pos?.index == lastItemIndex,
      orElse: () => null,
    );

    final isAtBottom = lastItem != null && lastItem.itemTrailingEdge <= 1.001;

    if (notification is ScrollUpdateNotification) {
      if (isAtBottom != _showNextSurahHint && !widget.isLoadingNextSurah) {
        setState(() => _showNextSurahHint = isAtBottom);
      }
      if (!isAtBottom) {
        _overscrollAtBottom = 0;
      } else if (!widget.isLoadingNextSurah) {
        final delta = notification.scrollDelta;
        if (delta != null && delta > 0) {
          _overscrollAtBottom += delta;
          if (_overscrollAtBottom >= _overscrollTriggerThreshold) {
            _overscrollAtBottom = 0;
            widget.onNextSurahTriggered();
          }
        }
      }
    }

    if (notification is OverscrollNotification &&
        notification.overscroll > 0 &&
        isAtBottom &&
        !widget.isLoadingNextSurah) {
      _overscrollAtBottom += notification.overscroll;
      if (_overscrollAtBottom >= _overscrollTriggerThreshold) {
        _overscrollAtBottom = 0;
        widget.onNextSurahTriggered();
      }
    }

    if (notification is ScrollEndNotification) {
      _overscrollAtBottom = 0;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.langCode;
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: ScrollablePositionedList.builder(
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: widget.details.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return listHeader(
              widget.surah.name(code),
              widget.surah.desc(code),
              widget.surah.surahTotal,
            );
          }

          if (index == widget.details.length + 1) {
            return nextSurahHint();
          }

          final data = widget.details[index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 75,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.tertiary,
                            Theme.of(
                              context,
                            ).colorScheme.tertiary.withValues(alpha: 0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiary.withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${data.chapterNo}:${data.verseNo}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 30),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      data.textAr,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.fontSize,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  data.text(code),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(
                      context,
                    ).colorScheme.onTertiary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 20),
                Visibility(
                  visible: index != widget.details.length - 1,
                  child: Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.onTertiary.withValues(alpha: 0.25),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget listHeader(String name, String text, int totalAyahs) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    '$totalAyahs ${AppLocalizations.of(context)!.ayah}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'بِسْمِ ٱللّٰهِ الرَّحْمَٰنِ الرَّحِيمِ',
                style: GoogleFonts.notoNaskhArabic(
                  fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget nextSurahHint() {
    final color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.6);
    final isLastSurah = widget.surah.id >= _maxSurahId;

    return AnimatedOpacity(
      opacity: (_showNextSurahHint || widget.isLoadingNextSurah) && !isLastSurah
          ? 1
          : 0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28.0),
        child: Center(
          child: widget.isLoadingNextSurah
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: color,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.keyboard_double_arrow_down_rounded,
                      color: color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Continue scrolling down to move to the next surah',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class SurahOptionsPanel extends StatelessWidget {
  final SurahModel surah;
  final ValueChanged<SurahModel> onSurahSelected;

  const SurahOptionsPanel({
    super.key,
    required this.surah,
    required this.onSurahSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SurahProvider>(
      builder: (context, provider, _) {
        final surahList = provider.surahList;
        final code = provider.code ?? 'en';

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.45,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: surahList.length,
              itemBuilder: (context, index) {
                final item = surahList[index];
                final isSelected = item.id == surah.id;

                return ListTile(
                  dense: true,
                  selected: isSelected,
                  selectedTileColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Text(
                      '${item.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  title: Text(
                    item.name(code),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: Text(
                    item.nameArab,
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onTap: () => onSurahSelected(item),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
