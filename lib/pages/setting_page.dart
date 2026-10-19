import 'package:country_flags/country_flags.dart';
import 'package:deenly/components/app_theme.dart';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/components/locale_provider.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/theme_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/pages/quran/staggered_entrance_widget.dart';
import 'package:deenly/pages/setting/prayer_adjustment_tile.dart';
import 'package:deenly/pages/setting/setting_section.dart';
import 'package:deenly/pages/setting/setting_tile.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

const String _privacyPolicyUrl =
    'https://andrehaliim.vercel.app/projects/deenly/privacy';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key, this.onSaved, this.showAppBar = true});

  final VoidCallback? onSaved;

  /// False when shown as a tab, where the main page already has an app bar.
  final bool showAppBar;

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  bool _isSaving = false;

  /// Unsaved edits. Rebuilt from the saved values every time the page
  /// opens, so changes that were never saved are discarded.
  final Map<String, int> _pendingAdjustments = {};
  String _version = '';

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _loadSettings();
    _loadVersion();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
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
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final drawerProvider = context.watch<DrawerProvider>();
    final l10n = AppLocalizations.of(context);

    final sections = <Widget>[
      SettingSection(
        title: l10n?.settingLanguageTitle ?? '',
        children: [
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, _) {
              final isIndonesian =
                  (localeProvider.locale ?? const Locale('en')).languageCode ==
                  'id';

              return SettingTile(
                icon: Icons.translate_rounded,
                title: 'Indonesia',
                titleSuffix: CountryFlag.fromLanguageCode(
                  'id',
                  theme: const ImageTheme(width: 28, height: 18),
                ),
                trailing: SettingSwitch(
                  value: isIndonesian,
                  onChanged: (value) {
                    localeProvider.setLocale(Locale(value ? 'id' : 'en'));
                  },
                ),
              );
            },
          ),
        ],
      ),
      SettingSection(
        title: l10n?.settingAppearanceTitle ?? '',
        children: [
          SettingTile(
            icon: Icons.dark_mode_rounded,
            title: l10n?.settingTheme ?? '',
            trailing: SettingSwitch(
              value: themeProvider.isDarkMode,
              onChanged: themeProvider.toggleTheme,
            ),
          ),
        ],
      ),
      SettingSection(
        title: l10n?.settingNotificationTitle ?? '',
        isExpanded: drawerProvider.isNotificationExpanded,
        onTitleTap: drawerProvider.toggleNotificationExpansion,
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
                    _onPrayerToggled(drawerProvider, prayer, value),
              ),
            ),
        ],
      ),
      SettingSection(
        title: l10n?.settingBeforeTitle ?? '',
        children: [
          SettingTile(
            icon: Icons.alarm_rounded,
            title: l10n?.settingBeforeValue ?? '',
            trailing: SettingSwitch(
              value: drawerProvider.isReminderEnabled,
              onChanged: (value) async {
                final success = await drawerProvider.toggleReminder(value);
                if (!success && mounted) {
                  _showSnackBar(
                    AppLocalizations.of(context)?.reminderEnableFailed ?? '',
                  );
                }
              },
            ),
          ),
        ],
      ),
      SettingSection(
        title: l10n?.settingTimeTitle ?? '',
        isExpanded: drawerProvider.isAdjustmentExpanded,
        onTitleTap: drawerProvider.toggleAdjustmentExpansion,
        children: [
          for (final prayer in DrawerProvider.prayers)
            PrayerAdjustmentTile(
              prayerName: PrayerProxy().getPrayerLabel(context, prayer),
              adjustment: _pendingAdjustments[prayer] ?? 0,
              onChanged: (value) {
                setState(() {
                  _pendingAdjustments[prayer] = value;
                });
              },
            ),
          _SaveButton(
            label: l10n?.settingSaveButton ?? '',
            isSaving: _isSaving,
            onPressed: () => _saveAdjustments(drawerProvider),
          ),
        ],
      ),
      SettingSection(
        title: l10n?.settingAboutTitle ?? '',
        children: [
          SettingTile(
            icon: Icons.privacy_tip_rounded,
            title: l10n?.settingPrivacyPolicy ?? '',
            onTap: _openPrivacyPolicy,
            trailing: Icon(
              Icons.open_in_new_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      if (kDebugMode)
        SettingSection(
          title: 'Debug',
          children: [
            SettingTile(
              icon: Icons.storage_rounded,
              title: 'Export DB',
              onTap: DatabaseHelper.instance.exportDB,
            ),
            SettingTile(
              icon: Icons.pending_actions_rounded,
              title: 'List Pending Notification',
              onTap: NotificationHelper().getPendingNotifications,
            ),
          ],
        ),
      _SettingFooter(version: _version),
    ];

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(
                l10n?.menuSetting ?? '',
                style: theme.extension<AppTextStyles>()?.brandTitle,
              ),
              iconTheme: IconThemeData(color: theme.colorScheme.primary),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            for (final (index, section) in sections.indexed)
              StaggeredEntrance(
                animation: _entranceController,
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: section,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPrayerToggled(
    DrawerProvider drawerProvider,
    String prayer,
    bool value,
  ) async {
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
        AppLocalizations.of(context)?.notificationScheduleFailed ?? '',
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
      _showSnackBar(AppLocalizations.of(context)?.couldNotOpenLink ?? '');
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

    /// toJson() keys match the prayer names ('Fajr', 'Dhuhr', ...).
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

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.label,
    required this.isSaving,
    required this.onPressed,
  });

  final String label;
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: isSaving ? null : onPressed,
          style: FilledButton.styleFrom(
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: isSaving
              ? SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : const Icon(Icons.check_rounded, size: 20),
          label: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSaving ? null : theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingFooter extends StatelessWidget {
  const _SettingFooter({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          'Deenly © 2026 @andrehaliim',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'v$version',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
