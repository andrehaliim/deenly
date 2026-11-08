import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/components/notification_permission_prompt.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/setting/notification_blocked_tile.dart';
import 'package:deenly/pages/setting/setting_info_card.dart';
import 'package:deenly/pages/setting/setting_section.dart';
import 'package:deenly/pages/setting/setting_subpage.dart';
import 'package:deenly/pages/setting/setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Turns the reminders for Islamic calendar events on or off.
class CalendarReminderPage extends StatelessWidget {
  const CalendarReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final drawerProvider = context.watch<DrawerProvider>();
    final l10n = AppLocalizations.of(context);

    return SettingSubpage(
      title: l10n?.settingCalendarMenu ?? '',
      children: [
        SettingInfoCard(
          icon: Icons.notifications_active_rounded,
          title: l10n?.settingCalendarInfoTitle ?? '',
          description: l10n?.settingCalendarInfoDesc ?? '',
        ),
        SettingSection(
          title: l10n?.settingCalendarTitle ?? '',
          children: [
            if (!drawerProvider.isNotificationAllowed)
              const NotificationBlockedTile(),
            SettingTile(
              icon: Icons.mosque_rounded,
              title: l10n?.settingCalendarHoliday ?? '',
              subtitle: l10n?.settingCalendarHolidayDesc,
              trailing: SettingSwitch(
                value: drawerProvider.isHolidayReminderEnabled,
                onChanged: (value) => _onToggled(
                  context,
                  drawerProvider.toggleHolidayReminder,
                  value,
                ),
              ),
            ),
            SettingTile(
              icon: Icons.nightlight_round,
              title: l10n?.settingCalendarSunnahFast ?? '',
              subtitle: l10n?.settingCalendarSunnahFastDesc,
              trailing: SettingSwitch(
                value: drawerProvider.isSunnahFastReminderEnabled,
                onChanged: (value) => _onToggled(
                  context,
                  drawerProvider.toggleSunnahFastReminder,
                  value,
                ),
              ),
            ),
            SettingTile(
              icon: Icons.date_range_rounded,
              title: l10n?.calendarMondayThursdayFast ?? '',
              subtitle: l10n?.settingCalendarMondayThursdayDesc,
              trailing: SettingSwitch(
                value: drawerProvider.isMondayThursdayReminderEnabled,
                onChanged: (value) => _onToggled(
                  context,
                  drawerProvider.toggleMondayThursdayReminder,
                  value,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Turning a reminder on asks for the notification permission first.
  Future<void> _onToggled(
    BuildContext context,
    Future<void> Function(bool) toggle,
    bool value,
  ) async {
    if (value && !await NotificationPermissionPrompt.ensure(context)) return;
    await toggle(value);
  }
}
