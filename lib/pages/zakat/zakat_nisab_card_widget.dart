import 'package:deenly/components/app_colors.dart';
import 'package:deenly/components/rupiah_format.dart';
import 'package:deenly/components/zakat_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

/// Hero card with today's nisab (85 g of gold) in Rupiah, and a note
/// when the price shown is not today's.
class ZakatNisabCard extends StatelessWidget {
  const ZakatNisabCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>();
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ZakatProvider>();
    final price = provider.price;
    final nisab = provider.nisab;
    final onHero = colorScheme.onPrimary;

    final String? note;
    if (provider.isDefaultPrice) {
      note = l10n?.zakatPriceDefault;
    } else if (provider.isStale) {
      note = l10n?.zakatPriceStale;
    } else {
      note = null;
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: appColors?.heroGradient,
        boxShadow: [
          BoxShadow(
            color: appColors?.heroShadow ?? colorScheme.shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 16,
            bottom: -20,
            child: FaIcon(
              FontAwesomeIcons.coins,
              size: 96,
              color: onHero.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.zakatNisabToday ?? '',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: onHero.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  child: nisab == null
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: onHero,
                            ),
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            RupiahFormat.currency(nisab),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: onHero,
                            ),
                          ),
                        ),
                ),
                if (price != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n?.zakatNisabInfo(
                          RupiahFormat.currency(price.goldPerGram),
                        ) ??
                        '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onHero.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                if (note != null) ...[
                  const SizedBox(height: 10),
                  _PriceNote(message: note),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceNote extends StatelessWidget {
  final String message;

  const _PriceNote({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: colorScheme.secondaryFixed,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
