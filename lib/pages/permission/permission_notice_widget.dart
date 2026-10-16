import 'package:flutter/material.dart';

/// Banner telling the user the permission was denied or blocked.
class PermissionNoticeWidget extends StatelessWidget {
  final String title;
  final String message;
  final bool isBlocked;

  const PermissionNoticeWidget({
    super.key,
    required this.title,
    required this.message,
    this.isBlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final background = isBlocked
        ? colorScheme.error.withValues(alpha: 0.12)
        : colorScheme.secondaryContainer;
    final titleColor = isBlocked
        ? colorScheme.error
        : colorScheme.onSecondaryContainer;
    final messageColor = isBlocked
        ? colorScheme.onSurface
        : colorScheme.onSecondaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isBlocked
                ? Icons.warning_amber_rounded
                : Icons.info_outline_rounded,
            size: 20,
            color: titleColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: messageColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
