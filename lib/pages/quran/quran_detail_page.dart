import 'package:deenly/components/audio_provider.dart';
import 'package:deenly/components/surah_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/surah_model.dart';
import 'package:deenly/pages/quran/jump_to_ayah_panel.dart';
import 'package:deenly/pages/quran/surah_detail_list.dart';
import 'package:deenly/pages/quran/surah_jump_controller.dart';
import 'package:deenly/pages/quran/surah_options_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  bool _showJumpPanel = false;
  final SurahJumpController _jumpController = SurahJumpController();

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

    context.read<AudioProvider>().stopAll();

    setState(() {
      _isLoadingNextSurah = false;
      _activeSurah = nextSurah;
      _isInitialSurah = false;
    });
  }

  void _toggleJumpPanel() {
    setState(() {
      _showJumpPanel = !_showJumpPanel;
      if (_showJumpPanel) _showOptions = false;
    });
  }

  void _onAyahSubmitted(int ayah) {
    FocusScope.of(context).unfocus();
    setState(() => _showJumpPanel = false);
    _jumpController.jumpTo(ayah);
  }

  void _toggleOptions() {
    setState(() {
      _showOptions = !_showOptions;
      if (_showOptions) _showJumpPanel = false;
    });
  }

  void _closePanels() {
    FocusScope.of(context).unfocus();
    setState(() {
      _showOptions = false;
      _showJumpPanel = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPanelOpen = _showOptions || _showJumpPanel;

    final Widget panel;
    if (_showJumpPanel) {
      panel = JumpToAyahPanel(
        key: ValueKey('jump-${_activeSurah.id}'),
        totalAyahs: _activeSurah.surahTotal,
        onAyahSubmitted: _onAyahSubmitted,
      );
    } else if (_showOptions) {
      panel = SurahOptionsPanel(
        key: const ValueKey('options'),
        surah: _activeSurah,
        onSurahSelected: (surah) async {
          if (surah.id == _activeSurah.id) {
            setState(() => _showOptions = false);
            return;
          }
          context.read<AudioProvider>().stopAll();
          setState(() {
            _activeSurah = surah;
            _isInitialSurah = true;
            _showOptions = false;
          });
          context.read<SurahProvider>().getSurahDetail(surah.id);
        },
      );
    } else {
      panel = const SizedBox(key: ValueKey('none'), width: double.infinity);
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<AudioProvider>().stopAll();
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 12,
          title: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _SurahTitleButton(
                    title: _activeSurah.name(widget.code),
                    isOpen: _showOptions,
                    onTap: _toggleOptions,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: _toggleJumpPanel,
                tooltip: AppLocalizations.of(context)?.jumpToAyah,
                isSelected: _showJumpPanel,
                icon: const Icon(Icons.format_list_numbered_rounded),
              ),
              const SizedBox(width: 4),
              Selector<AudioProvider, bool>(
                selector: (_, audio) => audio.playedSurah == _activeSurah.id,
                builder: (context, isPlaying, _) {
                  return IconButton.filled(
                    onPressed: () => context.read<AudioProvider>().playMultiple(
                      _activeSurah,
                      1,
                    ),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) =>
                          RotationTransition(
                            turns: Tween(
                              begin: 0.75,
                              end: 1.0,
                            ).animate(animation),
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          ),
                      child: Icon(
                        isPlaying
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        key: ValueKey(isPlaying),
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Consumer<SurahProvider>(
            builder: (context, provider, _) {
              final details = provider.surahDetail;
              if (details == null && provider.isDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (details == null) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)?.failedFetchSurahDetail ?? '',
                  ),
                );
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
                      details: details,
                      langCode: provider.code ?? 'en',
                      restorePosition: _isInitialSurah,
                      isLoadingNextSurah: _isLoadingNextSurah,
                      onNextSurahTriggered: _goToNextSurah,
                      juzFrom: widget.juzFrom,
                      jumpController: _jumpController,
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: !isPanelOpen,
                      child: AnimatedOpacity(
                        opacity: isPanelOpen ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: GestureDetector(
                          onTap: _closePanels,
                          child: ColoredBox(
                            color: colorScheme.scrim.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          alignment: Alignment.topCenter,
                          child: child,
                        ),
                      ),
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: [...previousChildren, ?currentChild],
                        );
                      },
                      child: panel,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SurahTitleButton extends StatelessWidget {
  final String title;
  final bool isOpen;
  final VoidCallback onTap;

  const _SurahTitleButton({
    required this.title,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isOpen
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.4),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Text(
                    title,
                    key: ValueKey(title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
