import 'package:deenly/components/app_colors.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<AppColors>();
    final selected = colors?.navSelected ?? colorScheme.primary;
    final onSelected = colors?.onNavSelected ?? colorScheme.onPrimary;
    final items = [
      {'icon': FontAwesomeIcons.house, 'label': l10n?.menuHome ?? ''},
      {
        'icon': FontAwesomeIcons.personPraying,
        'label': l10n?.menuPrayers ?? '',
      },
      {'icon': FontAwesomeIcons.bookQuran, 'label': l10n?.menuQuran ?? ''},
      {'icon': FontAwesomeIcons.gear, 'label': l10n?.menuSetting ?? ''},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? selected : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      items[index]['icon'] as FaIconData,
                      color: isSelected
                          ? onSelected
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index]['label'] as String,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? onSelected
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
