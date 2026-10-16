import 'package:country_flags/country_flags.dart';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/components/locale_provider.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/theme_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/pages/drawer/drawer_section_title.dart';
import 'package:deenly/pages/drawer/drawer_setting_tile.dart';
import 'package:deenly/pages/drawer/prayer_adjustment_tile.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

const String _privacyPolicyUrl =
    'https://andrehaliim.vercel.app/projects/deenly/privacy';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  bool _isSaving = false;

  // Unsaved edits. Rebuilt from the saved values every time the drawer
  // opens, so changes that were never saved are discarded.
  final Map<String, int> _pendingAdjustments = {};
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _version = packageInfo.version;
    });
  }

  void _loadSettings() {
    final drawerProvider = context.read<DrawerProvider>();
    for (final prayer in DrawerProvider.prayers) {
      _pendingAdjustments[prayer] = drawerProvider.adjustmentOf(prayer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final provider = Provider.of<ThemeProvider>(context);
    final drawerProvider = Provider.of<DrawerProvider>(context);
    final l10n = AppLocalizations.of(context)!;

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
                  l10n.menuSetting,
                  style: GoogleFonts.notoSerif(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DrawerSectionTitle(l10n.settingLanguageTitle),
              const SizedBox(height: 12),
              Consumer<LocaleProvider>(
                builder: (context, localeProvider, _) {
                  final isIndonesian =
                      (localeProvider.locale ?? const Locale('en'))
                          .languageCode ==
                      'id';

                  return DrawerSettingTile(
                    icon: Icons.language,
                    title: 'Indonesia',
                    titleSuffix: CountryFlag.fromLanguageCode(
                      'id',
                      theme: ImageTheme(width: 30, height: 20),
                    ),
                    trailing: DrawerSwitch(
                      scale: 1,
                      value: isIndonesian,
                      onChanged: (value) {
                        localeProvider.setLocale(Locale(value ? 'id' : 'en'));
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              DrawerSectionTitle(l10n.settingAppearanceTitle),
              const SizedBox(height: 12),
              DrawerSettingTile(
                icon: Icons.dark_mode_outlined,
                title: l10n.settingTheme,
                trailing: DrawerSwitch(
                  value: provider.isDarkMode,
                  onChanged: provider.toggleTheme,
                ),
              ),
              const SizedBox(height: 12),
              DrawerSectionTitle(l10n.settingNotificationTitle),
              const SizedBox(height: 12),
              for (final prayer in DrawerProvider.prayers) ...[
                _buildPrayerNotificationTile(prayer, drawerProvider),
                const SizedBox(height: 6),
              ],
              const SizedBox(height: 6),
              DrawerSectionTitle(l10n.settingBeforeTitle),
              const SizedBox(height: 12),
              DrawerSettingTile(
                icon: Icons.access_time,
                title: l10n.settingBeforeValue,
                trailing: DrawerSwitch(
                  value: drawerProvider.isReminderEnabled,
                  onChanged: (value) async {
                    final success = await drawerProvider.toggleReminder(value);
                    if (!success && context.mounted) {
                      _showSnackBar(
                        AppLocalizations.of(context)!.reminderEnableFailed,
                      );
                    }
                  },
                ),
              ),
              Row(
                children: [
                  DrawerSectionTitle(l10n.settingTimeTitle),
                  const Spacer(),
                  IconButton(
                    icon: drawerProvider.isAdjustmentExpanded
                        ? const Icon(Icons.arrow_drop_up)
                        : const Icon(Icons.arrow_drop_down),
                    onPressed: drawerProvider.toggleAdjustmentExpansion,
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
                        for (final prayer in DrawerProvider.prayers) ...[
                          PrayerAdjustmentTile(
                            prayerName: PrayerProxy().getPrayerLabel(
                              context,
                              prayer,
                            ),
                            adjustment: _pendingAdjustments[prayer] ?? 0,
                            onChanged: (value) {
                              setState(() {
                                _pendingAdjustments[prayer] = value;
                              });
                            },
                          ),
                          const SizedBox(height: 6),
                        ],
                        _buildSaveButton(drawerProvider),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DrawerSectionTitle(l10n.settingAboutTitle),
              const SizedBox(height: 12),
              DrawerSettingTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.settingPrivacyPolicy,
                onTap: _openPrivacyPolicy,
                trailing: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Icon(
                    Icons.open_in_new,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Visibility(
                visible: kDebugMode,
                child: _buildDebugButton('Export DB', () {
                  DatabaseHelper.instance.exportDB();
                }),
              ),
              Visibility(
                visible: kDebugMode,
                child: _buildDebugButton('List Pending Notification', () {
                  NotificationHelper().getPendingNotifications();
                }),
              ),
              const SizedBox(height: 20),
              _buildFooterText('Deenly © 2026 @andrehaliim'),
              const SizedBox(height: 5),
              _buildFooterText('v$_version'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerNotificationTile(
    String prayer,
    DrawerProvider drawerProvider,
  ) {
    final isEnabled = drawerProvider.isPrayerEnabled(prayer);

    return DrawerSettingTile(
      icon: isEnabled
          ? Icons.notifications_active_outlined
          : Icons.notifications_off_outlined,
      title: PrayerProxy().getPrayerLabel(context, prayer),
      trailing: DrawerSwitch(
        value: isEnabled,
        onChanged: (value) async {
          drawerProvider.togglePrayer(prayer, value);
          final success = await _schedulePrayerNotification(
            prayerName: prayer,
            notifId: DrawerProvider.notificationIdOf(prayer),
            isEnabled: value,
          );

          if (!success) {
            drawerProvider.togglePrayer(prayer, false);
            if (!mounted) return;
            _showSnackBar(
              AppLocalizations.of(context)!.notificationScheduleFailed,
            );
          }
        },
      ),
    );
  }

  Widget _buildSaveButton(DrawerProvider drawerProvider) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isSaving ? null : () => _saveAdjustments(drawerProvider),
        child: _isSaving
            ? const CircularProgressIndicator()
            : Text(
                AppLocalizations.of(context)!.settingSaveButton,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildDebugButton(String label, VoidCallback onPressed) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterText(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveAdjustments(DrawerProvider drawerProvider) async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    try {
      await drawerProvider.saveAdjustments(Map.of(_pendingAdjustments));
      widget.onSaved?.call();
    } catch (e) {
      debugPrint('Saving prayer adjustments failed: $e');
      final l10n = mounted ? AppLocalizations.of(context) : null;
      if (l10n != null) _showSnackBar(l10n.adjustmentSaveFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _openPrivacyPolicy() async {
    bool opened;
    try {
      opened = await launchUrl(
        Uri.parse(_privacyPolicyUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      opened = false;
    }

    if (!opened && mounted) {
      _showSnackBar(AppLocalizations.of(context)!.couldNotOpenLink);
    }
  }

  Future<bool> _schedulePrayerNotification({
    required String prayerName,
    required int notifId,
    required bool isEnabled,
  }) async {
    if (!isEnabled) {
      await NotificationHelper().cancelNotification(notifId);
      return true;
    }

    final PrayerModel? prayerModel = await PrayerProxy().getTodayPrayer();
    if (prayerModel == null) {
      return false;
    }

    // toJson() keys match the prayer names ('Fajr', 'Dhuhr', ...).
    final prayerTime = prayerModel.toJson()[prayerName] as String;
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
      debugPrint('Notification failed to schedule for $prayerName');
      return false;
    }

    return true;
  }
}
