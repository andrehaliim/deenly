import 'package:flutter/material.dart';

/// Rounded settings row: icon, title, optional [titleSuffix] and a
/// [trailing] control. Tappable when [onTap] is set.
class DrawerSettingTile extends StatelessWidget {
  const DrawerSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.trailing,
    this.titleSuffix,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget trailing;
  final Widget? titleSuffix;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(12);
    final suffix = titleSuffix;

    return Material(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (suffix != null) ...[const SizedBox(width: 12), suffix],
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact switch used as a [DrawerSettingTile.trailing] control.
class DrawerSwitch extends StatelessWidget {
  const DrawerSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.scale = 0.8,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Switch(
        padding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
