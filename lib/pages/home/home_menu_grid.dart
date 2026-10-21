import 'package:deenly/components/app_theme.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/asmaul_husna/asmaul_husna_page.dart';
import 'package:deenly/pages/doa/doa_page.dart';
import 'package:deenly/pages/mosque_page.dart';
import 'package:deenly/pages/qibla_page.dart';
import 'package:deenly/pages/tasbih_page.dart';
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

    /// Items without a page are not wired up yet, so taps do nothing.
    final items = [
      _MenuItem(
        FontAwesomeIcons.compass,
        l10n?.menuQibla ?? '',
        page: (_) => const QiblaPage(isActive: true),
      ),
      _MenuItem(
        FontAwesomeIcons.fingerprint,
        l10n?.menuTasbih ?? '',
        page: (_) => const TasbihPage(),
      ),
      _MenuItem(
        FontAwesomeIcons.mosque,
        l10n?.menuMosque ?? '',
        page: (_) => const MosquePage(isActive: true),
      ),
      _MenuItem(
        FontAwesomeIcons.handsPraying,
        l10n?.menuDoa ?? '',
        page: (_) => const DoaPage(),
      ),
      _MenuItem(
        FontAwesomeIcons.starAndCrescent,
        l10n?.menuAsmaulHusna ?? '',
        page: (_) => const AsmaulHusnaPage(),
      ),
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
  final WidgetBuilder? page;

  const _MenuItem(this.icon, this.label, {this.page});
}

class _MenuButton extends StatelessWidget {
  final _MenuItem item;

  const _MenuButton({required this.item});

  void _open(BuildContext context, WidgetBuilder page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _MenuPageScaffold(title: item.label, page: page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        final page = item.page;
        if (page != null) _open(context, page);
      },
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

/// Wraps a tool page, built to live inside the main page, with its own
/// app bar so it can be pushed from the menu.
class _MenuPageScaffold extends StatelessWidget {
  final String title;
  final WidgetBuilder page;

  const _MenuPageScaffold({required this.title, required this.page});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: theme.extension<AppTextStyles>()?.brandTitle),
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(top: false, child: page(context)),
    );
  }
}
