import 'dart:convert';

import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/pages/home/home_page.dart';
import 'package:deenly/pages/mosque_page.dart';
import 'package:deenly/components/custom_navigation_bar.dart';
import 'package:deenly/pages/qibla_page.dart';
import 'package:deenly/pages/quran/quran_page.dart';
import 'package:deenly/pages/tasbih_page.dart';
import 'package:deenly/components/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2;
  final List<Widget> _pages = [
    const QuranPage(),
    const MosquePage(),
    const HomePage(),
    const QiblaPage(),
    const TasbihPage(),
  ];

  bool _isFajrEnabled = false;
  bool _isDhuhrEnabled = false;
  bool _isAsrEnabled = false;
  bool _isMaghribEnabled = false;
  bool _isIshaEnabled = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final provider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Deenly',
          style: GoogleFonts.notoSerif(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      endDrawer: Drawer(
        width: width * 0.75,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Appearance',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: Theme.of(context).textTheme.labelMedium?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Prayer Notification',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: Theme.of(context).textTheme.labelMedium?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildPrayerNotificationSetting(
                prayerName: 'Fajr',
                notifId: 1,
                isEnabled: _isFajrEnabled,
                onChanged: (value) {
                  setState(() {
                    _isFajrEnabled = value;
                  });
                  _schedulePrayerNotification(
                    prayerName: 'Fajr',
                    notifId: 1,
                    isEnabled: value,
                  );
                },
              ),
              const SizedBox(height: 6),
              _buildPrayerNotificationSetting(
                prayerName: 'Dhuhr',
                notifId: 2,
                isEnabled: _isDhuhrEnabled,
                onChanged: (value) {
                  setState(() {
                    _isDhuhrEnabled = value;
                  });
                  _schedulePrayerNotification(
                    prayerName: 'Dhuhr',
                    notifId: 2,
                    isEnabled: value,
                  );
                },
              ),
              const SizedBox(height: 6),
              _buildPrayerNotificationSetting(
                prayerName: 'Asr',
                notifId: 3,
                isEnabled: _isAsrEnabled,
                onChanged: (value) {
                  setState(() {
                    _isAsrEnabled = value;
                  });
                  _schedulePrayerNotification(
                    prayerName: 'Asr',
                    notifId: 3,
                    isEnabled: value,
                  );
                },
              ),
              const SizedBox(height: 6),
              _buildPrayerNotificationSetting(
                prayerName: 'Maghrib',
                notifId: 4,
                isEnabled: _isMaghribEnabled,
                onChanged: (value) {
                  setState(() {
                    _isMaghribEnabled = value;
                  });
                  _schedulePrayerNotification(
                    prayerName: 'Maghrib',
                    notifId: 4,
                    isEnabled: value,
                  );
                },
              ),
              const SizedBox(height: 6),
              _buildPrayerNotificationSetting(
                prayerName: 'Isha',
                notifId: 5,
                isEnabled: _isIshaEnabled,
                onChanged: (value) {
                  setState(() {
                    _isIshaEnabled = value;
                  });
                  _schedulePrayerNotification(
                    prayerName: 'Isha',
                    notifId: 5,
                    isEnabled: value,
                  );
                },
              ),
              const Spacer(),
              Text(
                'Deenly © 2026 @andrehaliim',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
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

  Future<void> _schedulePrayerNotification({
    required String prayerName,
    required int notifId,
    required bool isEnabled,
  }) async {
    if (isEnabled) {
      final prefs = await SharedPreferences.getInstance();
      final String prayerData = prefs.getString('prayer_data') ?? '';

      final PrayerModel prayerModel = PrayerModel.fromJsonSaved(
        json.decode(prayerData),
      );

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

      await NotificationHelper().schedulePrayerNotification(
        notifId: notifId,
        prayerName: prayerName,
        scheduledTime: scheduledTime,
      );
    } else {
      await NotificationHelper().cancelNotification(notifId);
    }
  }
}
