import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
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
        SettingSection(
          title: l10n?.settingCalendarTitle ?? '',
          children: [
            SettingTile(
              icon: Icons.mosque_rounded,
              title: l10n?.settingCalendarHoliday ?? '',
              trailing: SettingSwitch(
                value: drawerProvider.isHolidayReminderEnabled,
                onChanged: drawerProvider.toggleHolidayReminder,
              ),
            ),
            SettingTile(
              icon: Icons.nightlight_round,
              title: l10n?.settingCalendarSunnahFast ?? '',
              trailing: SettingSwitch(
                value: drawerProvider.isSunnahFastReminderEnabled,
                onChanged: drawerProvider.toggleSunnahFastReminder,
              ),
            ),
            SettingTile(
              icon: Icons.date_range_rounded,
              title: l10n?.calendarMondayThursdayFast ?? '',
              trailing: SettingSwitch(
                value: drawerProvider.isMondayThursdayReminderEnabled,
                onChanged: drawerProvider.toggleMondayThursdayReminder,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
