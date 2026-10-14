import 'package:deenly/components/audio_provider.dart';
import 'package:deenly/components/surah_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/surah_model.dart';
import 'package:deenly/pages/quran/surah_detail_list.dart';
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<AudioProvider>().stopAll();
      },
      child: Scaffold(
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
                Spacer(),
                Consumer<AudioProvider>(
                  builder: (context, audioProvider, child) {
                    final isPlaying =
                        audioProvider.playedSurah == widget.surah.id;
                    return GestureDetector(
                      onTap: () {
                        audioProvider.playMultiple(_activeSurah, 1);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.stop_circle_outlined
                              : Icons.play_circle_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
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
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.failedFetchSurahDetail,
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
                        context.read<AudioProvider>().stopAll();
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
      ),
    );
  }
}
