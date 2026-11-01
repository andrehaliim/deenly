import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/setting/setting_info_card.dart';
import 'package:deenly/pages/setting/setting_section.dart';
import 'package:deenly/pages/setting/setting_subpage.dart';
import 'package:deenly/pages/setting/setting_tile.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Turns the adhan notification of each prayer on or off.
class PrayerNotificationPage extends StatelessWidget {
  const PrayerNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final drawerProvider = context.watch<DrawerProvider>();
    final l10n = AppLocalizations.of(context);

    return SettingSubpage(
      title: l10n?.settingNotificationTitle ?? '',
      children: [
        SettingInfoCard(
          icon: Icons.volume_up_rounded,
          title: l10n?.settingNotificationInfoTitle ?? '',
          description: l10n?.settingNotificationInfoDesc ?? '',
        ),
        SettingSection(
          children: [
            for (final prayer in DrawerProvider.prayers)
              SettingTile(
                icon: drawerProvider.isPrayerEnabled(prayer)
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                title: PrayerProxy().getPrayerLabel(context, prayer),
                trailing: SettingSwitch(
                  value: drawerProvider.isPrayerEnabled(prayer),
                  onChanged: (value) =>
                      _onPrayerToggled(context, drawerProvider, prayer, value),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _onPrayerToggled(
    BuildContext context,
    DrawerProvider drawerProvider,
    String prayer,
    bool value,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final message =
        AppLocalizations.of(context)?.notificationScheduleFailed ?? '';
    final success = await drawerProvider.setPrayerNotification(prayer, value);
    if (!success) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
