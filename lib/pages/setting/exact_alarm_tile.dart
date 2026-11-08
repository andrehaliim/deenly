import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/setting/setting_section.dart';
import 'package:deenly/pages/setting/setting_subpage.dart';
import 'package:deenly/pages/setting/setting_tile.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shows whether reminders can be exact and opens the system "Alarms &
/// reminders" screen on tap. The access is checked again when the user
/// comes back, and granting it reschedules every reminder as exact.
class ExactAlarmTile extends StatefulWidget {
  const ExactAlarmTile({super.key});

  @override
  State<ExactAlarmTile> createState() => _ExactAlarmTileState();
}

class _ExactAlarmTileState extends State<ExactAlarmTile>
    with WidgetsBindingObserver {
  final NotificationHelper _notificationHelper = NotificationHelper();

  /// Null until the first check is done.
  bool? _isExact;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final wasExact = _isExact;
    final isExact = await _notificationHelper.canScheduleExact();
    if (!mounted) return;
    setState(() => _isExact = isExact);
    if (wasExact == false && isExact) await _rescheduleAll();
  }

  Future<void> _rescheduleAll() async {
    try {
      final prayerModel = await PrayerProxy().getTodayPrayer();
      if (prayerModel == null) return;
      await _notificationHelper.rescheduleAll(prayerModel);
    } catch (e) {
      debugPrint('Rescheduling after exact alarm access failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isExact = _isExact;

    /// Exact access means nothing while notifications are blocked, so the
    /// tile is hidden until they are allowed.
    final isNotificationAllowed = context
        .watch<DrawerProvider>()
        .isNotificationAllowed;
    if (isExact == null || !isNotificationAllowed) {
      return const SizedBox.shrink();
    }

    /// Placed in a column with the section below it, so it brings its own
    /// gap and leaves none behind while hidden.
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SettingSection(
        children: [
          SettingTile(
            icon: isExact ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
            title: l10n?.settingExactAlarmTitle ?? '',
            subtitle: isExact
                ? l10n?.settingExactAlarmOn ?? ''
                : l10n?.settingExactAlarmOff ?? '',
            trailing: const SettingChevron(),
            onTap: _notificationHelper.requestExactAlarmPermission,
          ),
        ],
      ),
    );
  }
}
