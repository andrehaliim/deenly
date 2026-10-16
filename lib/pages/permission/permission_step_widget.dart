import 'package:flutter/material.dart';

/// Shared layout of a permission step: scrollable explanation on top and
/// the actions pinned to the bottom so they stay reachable on small screens.
class PermissionStepWidget extends StatelessWidget {
  final Widget hero;
  final String title;
  final String subtitle;
  final List<Widget> reasons;
  final IconData footnoteIcon;
  final String footnote;
  final Widget? notice;
  final Widget actions;

  const PermissionStepWidget({
    super.key,
    required this.hero,
    required this.title,
    required this.subtitle,
    required this.reasons,
    required this.footnoteIcon,
    required this.footnote,
    required this.actions,
    this.notice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final notice = this.notice;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                hero,
                const SizedBox(height: 24),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                for (final reason in reasons) ...[
                  reason,
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      footnoteIcon,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        footnote,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                if (notice != null) ...[const SizedBox(height: 16), notice],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: actions,
        ),
      ],
    );
  }
}
