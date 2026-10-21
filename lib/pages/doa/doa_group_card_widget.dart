import 'package:deenly/components/app_colors.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/doa_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A horizontal card for one doa category on a primary-to-gold gradient:
/// name, doa count and a chevron hinting that it opens the category.
class DoaGroupCard extends StatelessWidget {
  final DoaGroupModel group;
  final String name;
  final VoidCallback onTap;

  const DoaGroupCard({
    super.key,
    required this.group,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>();
    final l10n = AppLocalizations.of(context);
    final borderRadius = BorderRadius.circular(20);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: appColors?.heroGradient,
        boxShadow: [
          BoxShadow(
            color: appColors?.heroShadow ?? colorScheme.shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        child: InkWell(
          onTap: onTap,
          splashColor: colorScheme.onPrimary.withValues(alpha: 0.12),
          highlightColor: colorScheme.onPrimary.withValues(alpha: 0.06),
          child: Stack(
            children: [
              const _PrayingHandsWatermark(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _CountPill(
                            label: l10n?.doaCount(group.doaTotal) ?? '',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const _ChevronCircle(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A large, faint praying hands icon bleeding off the card's right edge.
class _PrayingHandsWatermark extends StatelessWidget {
  const _PrayingHandsWatermark();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimary;

    return Positioned(
      right: 28,
      bottom: -18,
      child: IgnorePointer(
        child: FaIcon(
          FontAwesomeIcons.handsPraying,
          size: 84,
          color: color.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final String label;

  const _CountPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.secondaryFixed.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.secondaryFixed,
        ),
      ),
    );
  }
}

class _ChevronCircle extends StatelessWidget {
  const _ChevronCircle();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.onPrimary.withValues(alpha: 0.15),
      ),
      child: Icon(
        Icons.chevron_right_rounded,
        size: 22,
        color: colorScheme.onPrimary,
      ),
    );
  }
}
