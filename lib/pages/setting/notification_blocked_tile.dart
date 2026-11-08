import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/setting/setting_subpage.dart';
import 'package:deenly/pages/setting/setting_tile.dart';
import 'package:deenly/proxys/location_proxy.dart';
import 'package:flutter/material.dart';

/// First row of a notification section while notifications are blocked in
/// the system settings. Tapping it opens the app settings to allow them.
class NotificationBlockedTile extends StatelessWidget {
  const NotificationBlockedTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingTile(
      icon: Icons.notifications_off_rounded,
      title: l10n?.settingNotificationBlockedTitle ?? '',
      subtitle: l10n?.settingNotificationBlockedDesc ?? '',
      trailing: const SettingChevron(),
      onTap: LocationProxy().openAppSettings,
    );
  }
}
