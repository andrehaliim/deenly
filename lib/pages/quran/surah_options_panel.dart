import 'package:deenly/components/surah_provider.dart';
import 'package:deenly/models/surah_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.15),
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
