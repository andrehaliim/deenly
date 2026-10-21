import 'package:deenly/components/app_colors.dart';
import 'package:deenly/pages/home/home_menu_grid.dart';
import 'package:flutter/material.dart';

/// One card on the prayer gradient: [header] on top, the tools menu as a
/// light sheet in the middle, and an optional [footer] below it.
class HomeOverviewCard extends StatelessWidget {
  final Widget header;
  final Widget? footer;

  /// Whether the card is given a bounded height; the [footer] then
  /// stretches to fill what the header and menu leave.
  final bool fillsHeight;

  const HomeOverviewCard({
    super.key,
    required this.header,
    this.footer,
    this.fillsHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: appColors?.heroGradient,
        image: const DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.cover,
          opacity: 0.12,
        ),
        boxShadow: [
          BoxShadow(
            color: appColors?.heroShadow ?? colorScheme.shadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const HomeMenuGrid(),
          if (footer case final footer?)
            Flexible(
              flex: fillsHeight ? 1 : 0,
              fit: FlexFit.tight,
              child: footer,
            ),
        ],
      ),
    );
  }
}
