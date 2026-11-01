import 'package:country_flags/country_flags.dart';
import 'package:deenly/components/audio_provider.dart';
import 'package:deenly/components/quran_settings_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/reciter_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Half-height sheet with the reader settings. The barrier stays light so
/// the ayahs behind it preview every change live; the sheet itself follows
/// the chosen reading theme.
class ReadingSettingsSheet extends StatefulWidget {
  const ReadingSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.12),
      builder: (_) => const ReadingSettingsSheet(),
    );
  }

  @override
  State<ReadingSettingsSheet> createState() => _ReadingSettingsSheetState();
}

class _ReadingSettingsSheetState extends State<ReadingSettingsSheet> {
  bool _showReciters = false;
  late final AudioProvider _audio;

  @override
  void initState() {
    super.initState();
    _audio = context.read<AudioProvider>();
  }

  @override
  void dispose() {
    // A qari sample shouldn't keep playing once the sheet is closed.
    if (_audio.previewReciterId != null) _audio.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<QuranSettingsProvider>();
    final appTheme = Theme.of(context);

    return AnimatedTheme(
      data: settings.readingTheme.resolve(appTheme.brightness),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          final colorScheme = Theme.of(context).colorScheme;

          // A Material (not a colored box) so list tiles can paint their
          // selection and ink on it.
          return Material(
            color: colorScheme.surfaceContainerLowest,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: Offset(
                            child is _ReciterList ? 0.15 : -0.15,
                            0,
                          ),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _showReciters
                        // Only the main page takes the sheet's controller, so
                        // two lists never share it mid-transition.
                        ? _ReciterList(
                            key: const ValueKey('reciters'),
                            onBack: () => setState(() => _showReciters = false),
                          )
                        : _MainSettings(
                            key: const ValueKey('main'),
                            appTheme: appTheme,
                            scrollController: scrollController,
                            onOpenReciters: () =>
                                setState(() => _showReciters = true),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MainSettings extends StatelessWidget {
  final ThemeData appTheme;
  final ScrollController scrollController;
  final VoidCallback onOpenReciters;

  const _MainSettings({
    super.key,
    required this.appTheme,
    required this.scrollController,
    required this.onOpenReciters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<QuranSettingsProvider>();

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          l10n?.quranSettings ?? '',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _SectionLabel(l10n?.quranSettingsDisplay ?? ''),
        Text(
          l10n?.quranReadingTheme ?? '',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final option in ReadingTheme.values) ...[
              if (option != ReadingTheme.values.first)
                const SizedBox(width: 10),
              Expanded(
                child: _ThemeOption(
                  option: option,
                  appTheme: appTheme,
                  label: switch (option) {
                    ReadingTheme.standard => l10n?.quranThemeStandard ?? '',
                    ReadingTheme.dark => l10n?.quranThemeDark ?? '',
                    ReadingTheme.sepia => l10n?.quranThemeSepia ?? '',
                  },
                  selected: settings.readingTheme == option,
                  onTap: () => settings.setReadingTheme(option),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _SizeSlider(
          label: l10n?.quranArabicSize ?? '',
          value: settings.arabicSize,
          min: QuranSettingsProvider.minArabicSize,
          max: QuranSettingsProvider.maxArabicSize,
          step: 2,
          onChanged: settings.setArabicSize,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n?.quranShowTranslation ?? ''),
          value: settings.showTranslation,
          onChanged: settings.setShowTranslation,
        ),
        _SizeSlider(
          label: l10n?.quranTranslationSize ?? '',
          value: settings.translationSize,
          min: QuranSettingsProvider.minTranslationSize,
          max: QuranSettingsProvider.maxTranslationSize,
          step: 1,
          onChanged: settings.showTranslation
              ? settings.setTranslationSize
              : null,
        ),
        const SizedBox(height: 16),
        _SectionLabel(l10n?.quranSettingsAudio ?? ''),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n?.quranReciter ?? ''),
          subtitle: Text(settings.reciter.label),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onOpenReciters,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n?.quranPlayTaawudz ?? ''),
          subtitle: Text(l10n?.quranIntroHint ?? ''),
          value: settings.playTaawudz,
          onChanged: settings.setPlayTaawudz,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n?.quranPlayBasmala ?? ''),
          subtitle: Text(l10n?.quranIntroHint ?? ''),
          value: settings.playBasmala,
          onChanged: settings.setPlayBasmala,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: theme.colorScheme.secondary,
        ),
      ),
    );
  }
}

/// Swatch of the page color the option applies, with its name below.
class _ThemeOption extends StatelessWidget {
  final ReadingTheme option;

  /// Standard previews the app theme's page color.
  final ThemeData appTheme;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.option,
    required this.appTheme,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final swatch = option.resolve(appTheme.brightness).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: swatch.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              'أ',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: swatch.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: swatch.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;

  /// Null disables the slider.
  final ValueChanged<double>? onChanged;

  const _SizeSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final enabled = onChanged != null;
    final textColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
            ),
            Text(
              value.round().toString(),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: enabled ? colorScheme.primary : textColor,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.text_decrease_rounded, size: 18, color: textColor),
            Expanded(
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: ((max - min) / step).round(),
                onChanged: onChanged,
              ),
            ),
            Icon(Icons.text_increase_rounded, size: 22, color: textColor),
          ],
        ),
      ],
    );
  }
}

class _ReciterList extends StatelessWidget {
  final VoidCallback onBack;

  const _ReciterList({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<QuranSettingsProvider>();
    final previewId = context.select<AudioProvider, String?>(
      (audio) => audio.previewReciterId,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Text(
              l10n?.quranReciter ?? '',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final reciter in ReciterModel.all)
          _ReciterTile(
            reciter: reciter,
            selected: settings.reciter.id == reciter.id,
            previewing: previewId == reciter.id,
            onSelect: () => settings.setReciter(reciter),
          ),
      ],
    );
  }
}

/// Card with the qari's name, flag and style, and a sample button styled
/// like the per-ayah play button.
class _ReciterTile extends StatelessWidget {
  final ReciterModel reciter;
  final bool selected;
  final bool previewing;
  final VoidCallback onSelect;

  const _ReciterTile({
    required this.reciter,
    required this.selected,
    required this.previewing,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: selected
            ? Color.alphaBlend(
                colorScheme.primary.withValues(alpha: 0.08),
                colorScheme.surfaceContainerLow,
              )
            : colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.6)
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reciter.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          CountryFlag.fromCountryCode(
                            reciter.countryCode,
                            theme: const ImageTheme(
                              width: 18,
                              height: 12,
                              shape: RoundedRectangle(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            reciter.style,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _PreviewButton(
                  previewing: previewing,
                  onTap: () =>
                      context.read<AudioProvider>().previewReciter(reciter),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gold ring when idle, filled gold while the sample plays.
class _PreviewButton extends StatelessWidget {
  final bool previewing;
  final VoidCallback onTap;

  const _PreviewButton({required this.previewing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: previewing
            ? colorScheme.secondary
            : colorScheme.secondary.withValues(alpha: 0.1),
        border: Border.all(
          color: previewing
              ? colorScheme.secondary
              : colorScheme.secondary.withValues(alpha: 0.6),
          width: 1.2,
        ),
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
                previewing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                key: ValueKey(previewing),
                size: 20,
                color: previewing
                    ? colorScheme.onSecondary
                    : colorScheme.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
