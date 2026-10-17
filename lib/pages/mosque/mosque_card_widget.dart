import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/mosque_model.dart';
import 'package:deenly/pages/quran/pressable_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MosqueCard extends StatelessWidget {
  final MosqueModel mosque;
  final VoidCallback onTap;

  const MosqueCard({super.key, required this.mosque, required this.onTap});

  /// Placeholder the proxy uses until reverse geocoding fills the address.
  static const _pendingAddress = 'Address pending...';

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.toInt()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final metaColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.8);
    final metaStyle = theme.textTheme.bodySmall?.copyWith(
      color: metaColor,
      height: 1.4,
    );
    final isPending = mosque.address == _pendingAddress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: PressableCard(
        onTap: onTap,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surfaceContainerLow,
              Color.alphaBlend(
                colorScheme.primary.withValues(alpha: 0.06),
                colorScheme.surfaceContainerLow,
              ),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/images/mosque.png',
                height: 84,
                fit: BoxFit.contain,
                color: colorScheme.primary.withValues(alpha: 0.08),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
              child: Row(
                children: [
                  const _MosqueBadge(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mosque.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _DistanceChip(label: _formatDistance(mosque.distance)),
                        const SizedBox(height: 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: isPending
                              ? _PendingAddress(style: metaStyle)
                              : Text(
                                  mosque.address ?? '',
                                  key: const ValueKey('address'),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: metaStyle,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _DirectionsIcon(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MosqueBadge extends StatelessWidget {
  const _MosqueBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: FaIcon(
        FontAwesomeIcons.mosque,
        size: 18,
        color: colorScheme.primary,
      ),
    );
  }
}

class _DistanceChip extends StatelessWidget {
  final String label;

  const _DistanceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.near_me_rounded,
            size: 12,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingAddress extends StatelessWidget {
  final TextStyle? style;

  const _PendingAddress({required this.style});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      key: const ValueKey('pending'),
      children: [
        SizedBox.square(
          dimension: 10,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: style?.color,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            l10n?.mosqueLoadAddress ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}

class _DirectionsIcon extends StatelessWidget {
  const _DirectionsIcon();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.directions_rounded,
        size: 20,
        color: colorScheme.secondary,
      ),
    );
  }
}
