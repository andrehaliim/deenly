import 'dart:async';

import 'package:deenly/components/audio_provider.dart';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/components/surah_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/surah_detail_model.dart';
import 'package:deenly/models/surah_model.dart';
import 'package:deenly/pages/quran/ayah_fast_scroller.dart';
import 'package:deenly/pages/quran/surah_jump_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sqflite/sqflite.dart';

class SurahDetailList extends StatefulWidget {
  final SurahModel surah;
  final List<SurahDetailModel> details;
  final String langCode;
  final bool restorePosition;
  final bool isLoadingNextSurah;
  final VoidCallback onNextSurahTriggered;
  final int juzFrom;
  final SurahJumpController? jumpController;

  const SurahDetailList({
    super.key,
    required this.surah,
    required this.details,
    required this.langCode,
    required this.restorePosition,
    required this.isLoadingNextSurah,
    required this.onNextSurahTriggered,
    required this.juzFrom,
    this.jumpController,
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
  static const int _fastScrollMinAyahs = 30;
  static const Duration _highlightDuration = Duration(milliseconds: 1400);
  int? _pendingIndex;
  Timer? _debounceTimer;
  int _lastPlayedAyah = -1;
  late final AudioProvider _audio;
  final ValueNotifier<int> _currentAyah = ValueNotifier(1);
  final ValueNotifier<int?> _highlightedAyah = ValueNotifier(null);
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();

    _addScrollListener();
    widget.jumpController?.attach(_jumpToAyah);

    /// Listened to here instead of in build, so audio updates only follow
    /// the playing ayah and do not rebuild the whole list.
    _audio = context.read<AudioProvider>();
    _audio.addListener(_onAudioChanged);

    if (widget.restorePosition && widget.juzFrom > 0) {
      _loadLastPosition();
    }
  }

  @override
  void dispose() {
    _audio.removeListener(_onAudioChanged);
    _debounceTimer?.cancel();
    _highlightTimer?.cancel();
    widget.jumpController?.detach(_jumpToAyah);
    _currentAyah.dispose();
    _highlightedAyah.dispose();
    _saveLastAyah(_pendingIndex);
    super.dispose();
  }

  void _addScrollListener() async {
    _itemPositionsListener.itemPositions.addListener(() {
      final positions = _itemPositionsListener.itemPositions.value;
      if (positions.isEmpty) return;

      _updateCurrentAyah(positions);

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

  /// Tracks the ayah at the top of the viewport. When the last ayah is fully
  /// visible it counts as current, so the fast-scroll thumb reaches the end.
  void _updateCurrentAyah(Iterable<ItemPosition> positions) {
    final total = widget.details.length;
    if (total == 0) return;

    final onScreen = positions.where((item) => item.itemTrailingEdge > 0);
    if (onScreen.isEmpty) return;

    final top = onScreen.reduce(
      (min, item) => item.itemLeadingEdge < min.itemLeadingEdge ? item : min,
    );
    final isLastAyahVisible = positions.any(
      (item) => item.index == total && item.itemTrailingEdge <= 1.0,
    );

    _currentAyah.value = (isLastAyahVisible ? total : top.index).clamp(
      1,
      total,
    );
  }

  void _jumpToAyah(int ayah, {bool highlight = true}) {
    if (!_itemScrollController.isAttached) return;
    final target = ayah.clamp(1, widget.details.length);
    _itemScrollController.jumpTo(index: target);

    if (!highlight) return;
    _highlightTimer?.cancel();
    _highlightedAyah.value = target;
    _highlightTimer = Timer(_highlightDuration, () {
      _highlightedAyah.value = null;
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
      } else if (!widget.isLoadingNextSurah &&
          notification.dragDetails != null) {
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
        notification.dragDetails != null &&
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

  void _onAudioChanged() {
    final audio = _audio;
    if (audio.playedSurah != widget.surah.id) {
      _lastPlayedAyah = -1;
      return;
    }
    if (audio.playedAyah == _lastPlayedAyah) return;

    final targetIndex = audio.playedAyah;
    _lastPlayedAyah = targetIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_itemScrollController.isAttached ||
          targetIndex < 0 ||
          targetIndex >= widget.details.length + 1) {
        return;
      }
      final positions = _itemPositionsListener.itemPositions.value;
      final lastItemIndex = widget.details.length + 1;
      final isAtBottom = positions.any(
        (pos) => pos.index == lastItemIndex && pos.itemTrailingEdge <= 1.05,
      );

      final isTargetFullyVisible = positions.any(
        (pos) =>
            pos.index == targetIndex &&
            pos.itemLeadingEdge >= 0.0 &&
            pos.itemTrailingEdge <= 1.0,
      );

      if (!isAtBottom && !isTargetFullyVisible) {
        _itemScrollController.scrollTo(
          index: targetIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.langCode;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final arabicStyle = GoogleFonts.notoNaskhArabic(
      textStyle: theme.textTheme.headlineMedium,
      fontWeight: FontWeight.w600,
      color: colorScheme.onTertiary,
    );
    final verseLabelStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: colorScheme.onTertiary,
    );
    final translationStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: colorScheme.onTertiary.withValues(alpha: 0.5),
    );

    final list = NotificationListener<ScrollNotification>(
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
          return Column(
            children: [
              Selector<AudioProvider, bool>(
                selector: (_, audio) =>
                    audio.playedAyah == data.verseNo &&
                    audio.playedSurah == widget.surah.id,
                builder: (context, isPlayingz, _) {
                  return ValueListenableBuilder<int?>(
                    valueListenable: _highlightedAyah,
                    builder: (context, highlightedAyah, child) {
                      final scheme = Theme.of(context).colorScheme;
                      final Color background;
                      if (isPlayingz) {
                        background = scheme.onPrimary;
                      } else if (highlightedAyah == data.verseNo) {
                        background = scheme.primaryContainer;
                      } else {
                        background = scheme.surface;
                      }
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: background,
                        ),
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(16),
                        child: child,
                      );
                    },
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
                                    Theme.of(context).colorScheme.tertiary
                                        .withValues(alpha: 0.75),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary
                                        .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${data.chapterNo}:${data.verseNo}',
                                style: verseLabelStyle,
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () async {
                                SurahProvider surahProvider =
                                    Provider.of<SurahProvider>(
                                      context,
                                      listen: false,
                                    );
                                final audio = context.read<AudioProvider>();
                                SurahModel surah = await surahProvider
                                    .getSurahById(data.chapterNo);
                                audio.playMultiple(surah, data.verseNo);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPlayingz
                                      ? Icons.stop_circle_outlined
                                      : Icons.play_circle_outline_rounded,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            ),
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
                              style: arabicStyle,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(data.text(code), style: translationStyle),
                      ],
                    ),
                  );
                },
              ),
              Divider(
                color: Theme.of(
                  context,
                ).colorScheme.onTertiary.withValues(alpha: 0.25),
              ),
            ],
          );
        },
      ),
    );

    if (widget.details.length < _fastScrollMinAyahs) return list;

    return Stack(
      children: [
        list,
        Positioned.fill(
          child: AyahFastScroller(
            totalAyahs: widget.details.length,
            currentAyah: _currentAyah,
            onAyahSelected: (ayah) => _jumpToAyah(ayah, highlight: false),
          ),
        ),
      ],
    );
  }

  Widget listHeader(String name, String text, int totalAyahs) {
    return Container(
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
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
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
              textStyle: Theme.of(context).textTheme.headlineSmall,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
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
                      AppLocalizations.of(context)!.continueScrollNextSurah,
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
