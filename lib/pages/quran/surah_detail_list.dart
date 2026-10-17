import 'dart:async';

import 'package:deenly/components/audio_provider.dart';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/surah_detail_model.dart';
import 'package:deenly/models/surah_model.dart';
import 'package:deenly/pages/quran/ayah_card_widget.dart';
import 'package:deenly/pages/quran/ayah_fast_scroller.dart';
import 'package:deenly/pages/quran/surah_detail_header_widget.dart';
import 'package:deenly/pages/quran/surah_jump_controller.dart';
import 'package:flutter/material.dart';
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
            return SurahDetailHeader(surah: widget.surah, langCode: code);
          }

          if (index == widget.details.length + 1) {
            return nextSurahHint();
          }

          final data = widget.details[index - 1];
          return AyahCard(
            data: data,
            surahId: widget.surah.id,
            langCode: code,
            highlightedAyah: _highlightedAyah,
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
