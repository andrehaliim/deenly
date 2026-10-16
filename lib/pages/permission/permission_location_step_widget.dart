import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/permission/permission_actions_widget.dart';
import 'package:deenly/pages/permission/permission_hero_widget.dart';
import 'package:deenly/pages/permission/permission_notice_widget.dart';
import 'package:deenly/pages/permission/permission_reason_widget.dart';
import 'package:deenly/pages/permission/permission_step_widget.dart';
import 'package:flutter/material.dart';

enum LocationStepState { initial, denied, blocked }

class PermissionLocationStepWidget extends StatelessWidget {
  final LocationStepState state;
  final bool isBusy;
  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;
  final VoidCallback onChooseCity;

  const PermissionLocationStepWidget({
    super.key,
    required this.state,
    required this.isBusy,
    required this.onAllow,
    required this.onOpenSettings,
    required this.onChooseCity,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBlocked = state == LocationStepState.blocked;

    final notice = switch (state) {
      LocationStepState.initial => null,
      LocationStepState.denied => PermissionNoticeWidget(
        title: l10n?.locationPermissionDenied ?? '',
        message: l10n?.permissionDeniedMessage ?? '',
      ),
      LocationStepState.blocked => PermissionNoticeWidget(
        title: l10n?.permissionBlockedTitle ?? '',
        message: l10n?.permissionBlockedMessage ?? '',
        isBlocked: true,
      ),
    };

    return PermissionStepWidget(
      hero: const PermissionHeroWidget(
        icon: Icons.mosque_rounded,
        badgeIcon: Icons.location_on_rounded,
      ),
      title: l10n?.permissionLocationTitle ?? '',
      subtitle: l10n?.permissionLocationSubtitle ?? '',
      reasons: [
        PermissionReasonWidget(
          icon: Icons.schedule_rounded,
          title: l10n?.permissionReasonPrayerTitle ?? '',
          body: l10n?.permissionReasonPrayerBody ?? '',
        ),
        PermissionReasonWidget(
          icon: Icons.explore_rounded,
          title: l10n?.permissionReasonQiblaTitle ?? '',
          body: l10n?.permissionReasonQiblaBody ?? '',
          highlight: true,
        ),
        PermissionReasonWidget(
          icon: Icons.mosque_outlined,
          title: l10n?.permissionReasonMosqueTitle ?? '',
          body: l10n?.permissionReasonMosqueBody ?? '',
        ),
      ],
      footnoteIcon: Icons.lock_outline_rounded,
      footnote: l10n?.permissionLocationPrivacy ?? '',
      notice: notice,
      actions: PermissionActionsWidget(
        primaryLabel: isBlocked
            ? l10n?.permissionOpenSettings ?? ''
            : l10n?.permissionAllowLocation ?? '',
        primaryIcon: isBlocked
            ? Icons.settings_rounded
            : Icons.my_location_rounded,
        onPrimary: isBlocked ? onOpenSettings : onAllow,
        secondaryLabel: l10n?.permissionChooseCityManually ?? '',
        secondaryIcon: Icons.location_city_rounded,
        onSecondary: onChooseCity,
        isBusy: isBusy,
      ),
    );
  }
}
