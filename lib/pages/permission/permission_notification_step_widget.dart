import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/permission/permission_actions_widget.dart';
import 'package:deenly/pages/permission/permission_hero_widget.dart';
import 'package:deenly/pages/permission/permission_reason_widget.dart';
import 'package:deenly/pages/permission/permission_step_widget.dart';
import 'package:flutter/material.dart';

class PermissionNotificationStepWidget extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onAllow;
  final VoidCallback onSkip;

  const PermissionNotificationStepWidget({
    super.key,
    required this.isBusy,
    required this.onAllow,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PermissionStepWidget(
      hero: const PermissionHeroWidget(
        icon: Icons.notifications_active_rounded,
        badgeIcon: Icons.access_time_filled_rounded,
      ),
      title: l10n?.permissionNotificationTitle ?? '',
      subtitle: l10n?.permissionNotificationSubtitle ?? '',
      reasons: [
        PermissionReasonWidget(
          icon: Icons.campaign_rounded,
          title: l10n?.permissionReasonAdhanTitle ?? '',
          body: l10n?.permissionReasonAdhanBody ?? '',
        ),
        PermissionReasonWidget(
          icon: Icons.alarm_rounded,
          title: l10n?.permissionReasonReminderTitle ?? '',
          body: l10n?.permissionReasonReminderBody ?? '',
          highlight: true,
        ),
      ],
      footnoteIcon: Icons.tune_rounded,
      footnote: l10n?.permissionNotificationHint ?? '',
      actions: PermissionActionsWidget(
        primaryLabel: l10n?.permissionAllowNotification ?? '',
        primaryIcon: Icons.notifications_rounded,
        onPrimary: onAllow,
        secondaryLabel: l10n?.permissionNotNow ?? '',
        secondaryIcon: Icons.schedule_rounded,
        onSecondary: onSkip,
        isBusy: isBusy,
      ),
    );
  }
}
