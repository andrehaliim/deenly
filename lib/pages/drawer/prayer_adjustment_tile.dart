import 'package:flutter/material.dart';

/// Row with -/+ buttons to shift a prayer time by whole minutes.
class PrayerAdjustmentTile extends StatelessWidget {
  const PrayerAdjustmentTile({
    super.key,
    required this.prayerName,
    required this.adjustment,
    required this.onChanged,
  });

  final String prayerName;
  final int adjustment;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      color: theme.colorScheme.onSurface,
      fontSize: theme.textTheme.bodyLarge?.fontSize,
      fontWeight: FontWeight.bold,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(prayerName, style: textStyle),
          const Spacer(),
          GestureDetector(
            child: Icon(Icons.remove, color: theme.colorScheme.primary),
            onTap: () => onChanged(adjustment - 1),
          ),
          const SizedBox(width: 12),
          Container(
            width: 50,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary),
            ),
            child: Center(
              child: Text(
                adjustment > 0 ? '+$adjustment' : adjustment.toString(),
                style: textStyle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            child: Icon(Icons.add, color: theme.colorScheme.primary),
            onTap: () => onChanged(adjustment + 1),
          ),
        ],
      ),
    );
  }
}
