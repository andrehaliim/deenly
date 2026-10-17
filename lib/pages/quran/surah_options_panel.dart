import 'dart:math' as math;

import 'package:deenly/components/surah_provider.dart';
import 'package:deenly/models/surah_model.dart';
import 'package:deenly/pages/quran/surah_number_badge_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SurahOptionsPanel extends StatefulWidget {
  final SurahModel surah;
  final ValueChanged<SurahModel> onSurahSelected;

  const SurahOptionsPanel({
    super.key,
    required this.surah,
    required this.onSurahSelected,
  });

  @override
  State<SurahOptionsPanel> createState() => _SurahOptionsPanelState();
}

class _SurahOptionsPanelState extends State<SurahOptionsPanel> {
  static const double _itemExtent = 60;
  static const BorderRadius _radius = BorderRadius.vertical(
    bottom: Radius.circular(24),
  );

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final surahList = context.read<SurahProvider>().surahList;
    final index = surahList.indexWhere((item) => item.id == widget.surah.id);

    /// Opens with the active surah near the top instead of at Al-Fatihah.
    _scrollController = ScrollController(
      initialScrollOffset: math.max(0, index - 1) * _itemExtent,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<SurahProvider>(
      builder: (context, provider, _) {
        final surahList = provider.surahList;
        final code = provider.code ?? 'en';

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.45,
          ),
          decoration: BoxDecoration(
            borderRadius: _radius,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: colorScheme.surface,
            borderRadius: _radius,
            clipBehavior: Clip.antiAlias,
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 8),
              itemExtent: _itemExtent,
              itemCount: surahList.length,
              itemBuilder: (context, index) {
                final item = surahList[index];
                final isSelected = item.id == widget.surah.id;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: colorScheme.primaryContainer.withValues(
                    alpha: 0.5,
                  ),
                  leading: SurahNumberBadge(number: item.id, size: 38),
                  title: Text(
                    item.name(code),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  trailing: Text(
                    item.nameArab,
                    style: GoogleFonts.notoNaskhArabic(
                      textStyle: theme.textTheme.titleMedium,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () => widget.onSurahSelected(item),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
