import 'package:deenly/components/database_helper.dart';
import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/theme_provider.dart';
import 'package:deenly/components/widget_helper.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  bool _isSaving = false;
  int savedFajrAdjustment = 0;
  int savedDhuhrAdjustment = 0;
  int savedAsrAdjustment = 0;
  int savedMaghribAdjustment = 0;
  int savedIshaAdjustment = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final prefs = Provider.of<DrawerProvider>(context, listen: false);
    savedFajrAdjustment = prefs.fajradjustment;
    savedDhuhrAdjustment = prefs.dhuhradjustment;
    savedAsrAdjustment = prefs.asradjustment;
    savedMaghribAdjustment = prefs.maghribadjustment;
    savedIshaAdjustment = prefs.ishadjustment;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final provider = Provider.of<ThemeProvider>(context);
    final drawerProvider = Provider.of<DrawerProvider>(context);

    return Drawer(
      width: width * 0.75,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'Settings',
                  style: GoogleFonts.notoSerif(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTitle('Appearance'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.dark_mode,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        padding: EdgeInsets.zero,
                        value: provider.isDarkMode,
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                        onChanged: (value) {
                          provider.toggleTheme(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTitle('Prayer Notification'),
              const SizedBox(height: 12),
              _buildPrayerNotificationSetting(
                prayerName: 'Fajr',
                notifId: 1,
                isEnabled: drawerProvider.isFajrEnabled,
                onChanged: (value) async {
                  drawerProvider.toggleFajr(value);
                  bool success = await _schedulePrayerNotification(
                    prayerName: 'Fajr',
                    notifId: 1,
                    isEnabled: value,
                  );

                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to schedule notification'),
                      ),
                    );
                    drawerProvider.toggleFajr(false);
                  }
                },
              ),
              const SizedBox(height: 6),
              _buildPrayerNotificationSetting(
                prayerName: 'Dhuhr',
                notifId: 2,
                isEnabled: drawerProvider.isDhuhrEnabled,
                onChanged: (value) async {
                  drawerProvider.toggleDhuhr(value);
                  bool success = await _schedulePrayerNotification(
                    prayerName: 'Dhuhr',
                    notifId: 2,
                    isEnabled: value,
                  );

                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to schedule notification'),
                      ),
                    );
                    drawerProvider.toggleDhuhr(false);
                  }
                },
              ),
              const SizedBox(height: 6),
              _buildPrayerNotificationSetting(
                prayerName: 'Asr',
                notifId: 3,
                isEnabled: drawerProvider.isAsrEnabled,
                onChanged: (value) async {
                  drawerProvider.toggleAsr(value);
                  bool success = await _schedulePrayerNotification(
                    prayerName: 'Asr',
                    notifId: 3,
                    isEnabled: value,
                  );

                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to schedule notification'),
                      ),
                    );
                    drawerProvider.toggleAsr(false);
                  }
                },
              ),
              const SizedBox(height: 6),
              _buildPrayerNotificationSetting(
                prayerName: 'Maghrib',
                notifId: 4,
                isEnabled: drawerProvider.isMaghribEnabled,
                onChanged: (value) async {
                  drawerProvider.toggleMaghrib(value);
                  bool success = await _schedulePrayerNotification(
                    prayerName: 'Maghrib',
                    notifId: 4,
                    isEnabled: value,
                  );

                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to schedule notification'),
                      ),
                    );
                    drawerProvider.toggleMaghrib(false);
                  }
                },
              ),
              const SizedBox(height: 6),
              _buildPrayerNotificationSetting(
                prayerName: 'Isha',
                notifId: 5,
                isEnabled: drawerProvider.isIshaEnabled,
                onChanged: (value) async {
                  drawerProvider.toggleIsha(value);
                  bool success = await _schedulePrayerNotification(
                    prayerName: 'Isha',
                    notifId: 5,
                    isEnabled: value,
                  );

                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to schedule notification'),
                      ),
                    );
                    drawerProvider.toggleIsha(false);
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildTitle('Time Adjustment'),
                  const Spacer(),
                  IconButton(
                    icon: drawerProvider.isAdjustmentExpanded
                        ? const Icon(Icons.arrow_drop_up)
                        : const Icon(Icons.arrow_drop_down),
                    onPressed: () {
                      drawerProvider.toggleAdjustmentExpansion();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: ClipRect(
                  child: AnimatedAlign(
                    alignment: Alignment.topCenter,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    heightFactor: drawerProvider.isAdjustmentExpanded
                        ? 1.0
                        : 0.0,
                    child: Column(
                      children: [
                        _buildPrayerTimeAdjustment(
                          'Fajr',
                          drawerProvider.fajradjustment,
                          (value) {
                            drawerProvider.setFajrAdjustment(value);
                          },
                        ),

                        const SizedBox(height: 6),
                        _buildPrayerTimeAdjustment(
                          'Dhuhr',
                          drawerProvider.dhuhradjustment,
                          (value) {
                            drawerProvider.setDhuhrAdjustment(value);
                          },
                        ),
                        const SizedBox(height: 6),
                        _buildPrayerTimeAdjustment(
                          'Asr',
                          drawerProvider.asradjustment,
                          (value) {
                            drawerProvider.setAsrAdjustment(value);
                          },
                        ),
                        const SizedBox(height: 6),
                        _buildPrayerTimeAdjustment(
                          'Maghrib',
                          drawerProvider.maghribadjustment,
                          (value) {
                            drawerProvider.setMaghribAdjustment(value);
                          },
                        ),
                        const SizedBox(height: 6),
                        _buildPrayerTimeAdjustment(
                          'Isha',
                          drawerProvider.ishadjustment,
                          (value) {
                            drawerProvider.setIshaAdjustment(value);
                          },
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                _isSaving = true;
                              });
                              final adjustments = {
                                'fajr':
                                    drawerProvider.fajradjustment -
                                    savedFajrAdjustment,
                                'dhuhr':
                                    drawerProvider.dhuhradjustment -
                                    savedDhuhrAdjustment,
                                'asr':
                                    drawerProvider.asradjustment -
                                    savedAsrAdjustment,
                                'maghrib':
                                    drawerProvider.maghribadjustment -
                                    savedMaghribAdjustment,
                                'isha':
                                    drawerProvider.ishadjustment -
                                    savedIshaAdjustment,
                              };

                              await PrayerProxy().updatePrayerTimesInDB(
                                adjustments,
                              );
                              final PrayerModel? prayerModel =
                                  await PrayerProxy().getTodayPrayer();
                              if (prayerModel != null) {
                                await WidgetHelper().updateWidgetPrayer(
                                  prayerModel,
                                );
                              }
                              debugPrint(
                                'Fajr adjustment: ${drawerProvider.fajradjustment} - ${savedFajrAdjustment} = ${drawerProvider.fajradjustment - savedFajrAdjustment}',
                              );
                              debugPrint(
                                'Dhuhr adjustment: ${drawerProvider.dhuhradjustment} - ${savedDhuhrAdjustment} = ${drawerProvider.dhuhradjustment - savedDhuhrAdjustment}',
                              );
                              debugPrint(
                                'Asr adjustment: ${drawerProvider.asradjustment} - ${savedAsrAdjustment} = ${drawerProvider.asradjustment - savedAsrAdjustment}',
                              );
                              debugPrint(
                                'Maghrib adjustment: ${drawerProvider.maghribadjustment} - ${savedMaghribAdjustment} = ${drawerProvider.maghribadjustment - savedMaghribAdjustment}',
                              );
                              debugPrint(
                                'Isha adjustment: ${drawerProvider.ishadjustment} - ${savedIshaAdjustment} = ${drawerProvider.ishadjustment - savedIshaAdjustment}',
                              );
                              setState(() {
                                savedFajrAdjustment =
                                    drawerProvider.fajradjustment;
                                savedDhuhrAdjustment =
                                    drawerProvider.dhuhradjustment;
                                savedAsrAdjustment =
                                    drawerProvider.asradjustment;
                                savedMaghribAdjustment =
                                    drawerProvider.maghribadjustment;
                                savedIshaAdjustment =
                                    drawerProvider.ishadjustment;
                                _isSaving = false;
                              });
                              widget.onSaved?.call();
                            },
                            child: _isSaving
                                ? const CircularProgressIndicator()
                                : Text(
                                    'Save',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontSize: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Visibility(
                visible: kDebugMode,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      DatabaseHelper.instance.exportDB();
                    },
                    child: Text(
                      'Export DB',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: Theme.of(
                          context,
                        ).textTheme.titleMedium?.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: kDebugMode,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () async {
                      await NotificationHelper().getPendingNotifications();
                    },
                    child: Text(
                      'List Pending Notification',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: Theme.of(
                          context,
                        ).textTheme.titleMedium?.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Deenly © 2026 @andrehaliim',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: Theme.of(context).textTheme.labelMedium?.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPrayerNotificationSetting({
    required String prayerName,
    required int notifId,
    required bool isEnabled,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.notifications : Icons.notifications_off,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            prayerName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              padding: EdgeInsets.zero,
              value: isEnabled,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeAdjustment(
    String prayerName,
    int adjustment,
    Function(int) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.only(
        left: 12.0,
        right: 12.0,
        top: 6.0,
        bottom: 6.0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            prayerName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          GestureDetector(
            child: Icon(
              Icons.remove,
              color: Theme.of(context).colorScheme.primary,
            ),
            onTap: () {
              onChanged(adjustment - 1);
            },
          ),
          const SizedBox(width: 12),
          Container(
            width: 50,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.primary),
            ),
            child: Center(
              child: Text(
                adjustment > 0 ? '+$adjustment' : adjustment.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.primary,
            ),
            onTap: () {
              onChanged(adjustment + 1);
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _schedulePrayerNotification({
    required String prayerName,
    required int notifId,
    required bool isEnabled,
  }) async {
    if (isEnabled) {
      final PrayerModel? prayerModel = await PrayerProxy().getTodayPrayer();
      if (prayerModel == null) {
        return false;
      }

      String prayerTime = '';

      switch (prayerName) {
        case 'Fajr':
          prayerTime = prayerModel.fajr;
          break;
        case 'Dhuhr':
          prayerTime = prayerModel.dhuhr;
          break;
        case 'Asr':
          prayerTime = prayerModel.asr;
          break;
        case 'Maghrib':
          prayerTime = prayerModel.maghrib;
          break;
        case 'Isha':
          prayerTime = prayerModel.isha;
          break;
      }

      final parts = prayerTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = DateTime.now();

      DateTime prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (prayerDateTime.isBefore(now)) {
        prayerDateTime = prayerDateTime.add(const Duration(days: 1));
      }

      final scheduledTime = tz.TZDateTime.from(prayerDateTime, tz.local);

      bool isScheduled = await NotificationHelper().schedulePrayerNotification(
        notifId: notifId,
        prayerName: prayerName,
        scheduledTime: scheduledTime,
      );

      if (!isScheduled) {
        debugPrint("Notification failed to schedule for $prayerName");
        return false;
      }

      return true;
    } else {
      await NotificationHelper().cancelNotification(notifId);
      return true;
    }
  }
}
