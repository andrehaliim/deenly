import 'package:deenly/components/audio_provider.dart';
import 'package:deenly/components/surah_provider.dart';
import 'package:deenly/models/surah_detail_model.dart';
import 'package:deenly/pages/quran/ayah_number_badge_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AyahCard extends StatelessWidget {
  final SurahDetailModel data;
  final int surahId;
  final String langCode;
  final ValueListenable<int?> highlightedAyah;

  const AyahCard({
    super.key,
    required this.data,
    required this.surahId,
    required this.langCode,
    required this.highlightedAyah,
  });

  Future<void> _play(BuildContext context) async {
    final surahProvider = context.read<SurahProvider>();
    final audio = context.read<AudioProvider>();
    final surah = await surahProvider.getSurahById(data.chapterNo);
    audio.playMultiple(surah, data.verseNo);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Selector<AudioProvider, bool>(
      selector: (_, audio) =>
          audio.playedAyah == data.verseNo && audio.playedSurah == surahId,
      builder: (context, isPlaying, _) {
        return ValueListenableBuilder<int?>(
          valueListenable: highlightedAyah,
          builder: (context, highlighted, child) {
            final isHighlighted = highlighted == data.verseNo;
            final Color background;
            final Color border;
            if (isPlaying) {
              background = Color.alphaBlend(
                colorScheme.primary.withValues(alpha: 0.1),
                colorScheme.surfaceContainerLow,
              );
              border = colorScheme.primary.withValues(alpha: 0.6);
            } else if (isHighlighted) {
              background = colorScheme.tertiaryContainer;
              border = colorScheme.secondary;
            } else {
              background = colorScheme.surfaceContainerLow;
              border = colorScheme.outlineVariant.withValues(alpha: 0.5);
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border, width: isPlaying ? 1.5 : 1),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isPlaying ? colorScheme.primary : colorScheme.shadow)
                            .withValues(alpha: isPlaying ? 0.15 : 0.04),
                    blurRadius: isPlaying ? 16 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AyahNumberBadge(number: data.verseNo),
                  const SizedBox(width: 8),
                  const Spacer(),
                  _AyahPlayButton(
                    isPlaying: isPlaying,
                    onTap: () => _play(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Text(
                  data.textAr,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.notoNaskhArabic(
                    textStyle: theme.textTheme.headlineMedium,
                    fontWeight: FontWeight.w600,
                    height: 1.9,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data.text(langCode),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AyahPlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _AyahPlayButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPlaying ? colorScheme.primary : colorScheme.primaryContainer,
      ),
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                key: ValueKey(isPlaying),
                size: 20,
                color: isPlaying
                    ? colorScheme.onPrimary
                    : colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
