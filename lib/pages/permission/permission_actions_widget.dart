import 'package:flutter/material.dart';

/// Primary and secondary buttons at the bottom of a permission step.
class PermissionActionsWidget extends StatelessWidget {
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final IconData secondaryIcon;
  final VoidCallback onSecondary;
  final bool isBusy;

  const PermissionActionsWidget({
    super.key,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.secondaryIcon,
    required this.onSecondary,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: isBusy ? null : onPrimary,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          icon: isBusy
              ? SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : Icon(primaryIcon, size: 20),
          label: Text(primaryLabel),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: isBusy ? null : onSecondary,
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: colorScheme.onSurface,
          ),
          icon: Icon(secondaryIcon, size: 20),
          label: Text(secondaryLabel),
        ),
      ],
    );
  }
}
