import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 4x2 grid of shortcuts to the app's tools on the home page.
class HomeMenuGrid extends StatelessWidget {
  const HomeMenuGrid({super.key});

  static const int _columns = 4;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    /// Pages are not wired up yet, so taps do nothing for now.
    final items = [
      _MenuItem(FontAwesomeIcons.compass, l10n?.menuQibla ?? ''),
      _MenuItem(FontAwesomeIcons.fingerprint, l10n?.menuTasbih ?? ''),
      _MenuItem(FontAwesomeIcons.mosque, l10n?.menuMosque ?? ''),
      _MenuItem(FontAwesomeIcons.handsPraying, l10n?.menuDoa ?? ''),
      _MenuItem(FontAwesomeIcons.starAndCrescent, l10n?.menuAsmaulHusna ?? ''),
      _MenuItem(FontAwesomeIcons.bookOpen, l10n?.menuDzikir ?? ''),
      _MenuItem(FontAwesomeIcons.calendarDays, l10n?.menuCalendar ?? ''),
      _MenuItem(FontAwesomeIcons.handHoldingDollar, l10n?.menuZakat ?? ''),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var row = 0; row < items.length / _columns; row++)
            Row(
              children: [
                for (final item in items.skip(row * _columns).take(_columns))
                  Expanded(child: _MenuButton(item: item)),
              ],
            ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final FaIconData icon;
  final String label;

  const _MenuItem(this.icon, this.label);
}

class _MenuButton extends StatelessWidget {
  final _MenuItem item;

  const _MenuButton({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      // TODO: open the matching page once it is wired up.
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: FaIcon(item.icon, size: 22, color: colorScheme.primary),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                maxLines: 1,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
