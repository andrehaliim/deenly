import 'package:country_flags/country_flags.dart';
import 'package:deenly/components/app_theme.dart';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/components/locale_provider.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/notification_permission_prompt.dart';
import 'package:deenly/components/prayer_method_helper.dart';
import 'package:deenly/components/quran_settings_provider.dart';
import 'package:deenly/components/theme_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/quran/reading_settings_sheet.dart';
import 'package:deenly/pages/quran/staggered_entrance_widget.dart';
import 'package:deenly/pages/setting/calendar_reminder_page.dart';
import 'package:deenly/pages/setting/notification_blocked_tile.dart';
import 'package:deenly/pages/setting/prayer_adjustment_page.dart';
import 'package:deenly/pages/setting/prayer_notification_page.dart';
import 'package:deenly/pages/setting/setting_list_view.dart';
import 'package:deenly/pages/setting/setting_section.dart';
import 'package:deenly/pages/setting/setting_subpage.dart';
import 'package:deenly/pages/setting/setting_tile.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const String _privacyPolicyUrl =
    'https://www.andrehaliim.com/projects/deenly/privacy';

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
  bool _isApplyingCalculation = false;

  /// Dropdown value for the automatic (country based) option.
  static const int _automatic = -1;

  String _version = '';

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final drawerProvider = context.watch<DrawerProvider>();
    final l10n = AppLocalizations.of(context);

    final adjustedCount = DrawerProvider.prayers
        .where((prayer) => drawerProvider.adjustmentOf(prayer) != 0)
        .length;
    final enabledPrayerCount = DrawerProvider.prayers
        .where(drawerProvider.isPrayerEnabled)
        .length;
    final calendarReminders = [
      drawerProvider.isHolidayReminderEnabled,
      drawerProvider.isSunnahFastReminderEnabled,
      drawerProvider.isMondayThursdayReminderEnabled,
    ];

    final sections = <Widget>[
      SettingSection(
        title: l10n?.settingGeneralTitle ?? '',
        children: [
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, _) {
              final isIndonesian =
                  (localeProvider.locale ?? LocaleProvider.defaultLocale)
                      .languageCode ==
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
                  onChanged: (value) => _onLanguageChanged(
                    localeProvider,
                    Locale(value ? 'id' : 'en'),
                  ),
                ),
              );
            },
          ),
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
        title: l10n?.menuQuran ?? '',
        children: [
          SettingTile(
            icon: Icons.menu_book_rounded,
            title: l10n?.quranSettings ?? '',
            subtitle: context.select<QuranSettingsProvider, String>(
              (settings) => settings.reciter.label,
            ),
            trailing: const SettingChevron(),
            onTap: () => ReadingSettingsSheet.show(context),
          ),
        ],
      ),
      SettingSection(
        title: l10n?.settingPrayerTitle ?? '',
        children: [
          ..._calculationTiles(drawerProvider, l10n),
          SettingTile(
            icon: Icons.tune_rounded,
            title: l10n?.settingTimeTitle ?? '',
            subtitle: l10n?.settingAdjustmentSummary(adjustedCount),
            trailing: const SettingChevron(),
            onTap: () => _open(PrayerAdjustmentPage(onSaved: widget.onSaved)),
          ),
        ],
      ),
      SettingSection(
        title: l10n?.settingNotificationsTitle ?? '',
        children: [
          if (!drawerProvider.isNotificationAllowed)
            const NotificationBlockedTile(),
          SettingTile(
            icon: Icons.notifications_active_rounded,
            title: l10n?.settingNotificationTitle ?? '',
            subtitle: l10n?.settingEnabledCount(
              enabledPrayerCount,
              DrawerProvider.prayers.length,
            ),
            trailing: const SettingChevron(),
            onTap: () => _open(const PrayerNotificationPage()),
          ),
          SettingTile(
            icon: Icons.alarm_rounded,
            title: l10n?.settingPrayerReminderTitle ?? '',
            trailing: SettingSwitch(
              value: drawerProvider.isPrayerReminderEnabled,
              onChanged: (value) => _onReminderToggled(
                drawerProvider.togglePrayerReminder,
                value,
              ),
            ),
          ),
          SettingTile(
            icon: Icons.auto_awesome_rounded,
            title: l10n?.settingDzikirTitle ?? '',
            trailing: SettingSwitch(
              value: drawerProvider.isDzikirReminderEnabled,
              onChanged: (value) => _onReminderToggled(
                drawerProvider.toggleDzikirReminder,
                value,
              ),
            ),
          ),
          SettingTile(
            icon: Icons.event_rounded,
            title: l10n?.settingCalendarMenu ?? '',
            subtitle: l10n?.settingEnabledCount(
              calendarReminders.where((enabled) => enabled).length,
              calendarReminders.length,
            ),
            trailing: const SettingChevron(),
            onTap: () => _open(const CalendarReminderPage()),
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
              onTap: () => NotificationHelper().logNotificationStatus('manual'),
            ),
            SettingTile(
              icon: Icons.notification_add_rounded,
              title: 'Test Notif',
              onTap: () => NotificationHelper().showNotification(
                id: 9999,
                title: 'Deenly',
                body: 'Test notification',
              ),
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
        child: SettingListView(
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

  List<Widget> _calculationTiles(
    DrawerProvider drawerProvider,
    AppLocalizations? l10n,
  ) {
    final method = drawerProvider.prayerMethod;
    final school = drawerProvider.prayerSchool;
    final country = drawerProvider.prayerCountry;
    final autoMethod = PrayerMethodHelper.methodOf(
      PrayerMethodHelper.methodFor(country),
    );
    final autoSchool = PrayerMethodHelper.schoolFor(country);

    String schoolLabel(int school) => school == PrayerMethodHelper.schoolHanafi
        ? l10n?.settingSchoolHanafi ?? ''
        : l10n?.settingSchoolShafi ?? '';

    void apply({required int? method, required int? school}) =>
        _onCalculationChanged(drawerProvider, method: method, school: school);

    return [
      SettingDropdownTile<int>(
        icon: Icons.calculate_rounded,
        title: l10n?.settingMethod ?? '',
        value: method ?? _automatic,
        items: [
          SettingDropdownItem(
            value: _automatic,
            label: l10n?.settingAutomatic(autoMethod.shortName) ?? '',
          ),
          for (final option in PrayerMethodHelper.methods)
            SettingDropdownItem(value: option.id, label: option.name),
        ],
        onChanged: _isApplyingCalculation
            ? null
            : (value) => apply(
                method: value == _automatic ? null : value,
                school: school,
              ),
      ),
      SettingDropdownTile<int>(
        icon: Icons.wb_twilight_rounded,
        title: l10n?.settingSchool ?? '',
        value: school ?? _automatic,
        items: [
          SettingDropdownItem(
            value: _automatic,
            label: l10n?.settingAutomatic(schoolLabel(autoSchool)) ?? '',
          ),
          for (final option in [
            PrayerMethodHelper.schoolShafi,
            PrayerMethodHelper.schoolHanafi,
          ])
            SettingDropdownItem(value: option, label: schoolLabel(option)),
        ],
        onChanged: _isApplyingCalculation
            ? null
            : (value) => apply(
                method: method,
                school: value == _automatic ? null : value,
              ),
      ),
      if (_isApplyingCalculation)
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: LinearProgressIndicator(),
        ),
    ];
  }

  Future<void> _onCalculationChanged(
    DrawerProvider drawerProvider, {
    required int? method,
    required int? school,
  }) async {
    if (_isApplyingCalculation) return;
    setState(() {
      _isApplyingCalculation = true;
    });

    try {
      await drawerProvider.setPrayerCalculation(method: method, school: school);
      widget.onSaved?.call();
    } catch (e) {
      debugPrint('Applying prayer calculation failed: $e');
      final l10n = mounted ? AppLocalizations.of(context) : null;
      if (l10n != null) _showSnackBar(l10n.calculationSaveFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingCalculation = false;
        });
      }
    }
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Shows a message when [toggle] could not turn the reminder on.
  Future<void> _onReminderToggled(
    Future<bool> Function(bool) toggle,
    bool value,
  ) async {
    if (value && !await NotificationPermissionPrompt.ensure(context)) return;
    final success = await toggle(value);
    if (!success && mounted) {
      _showSnackBar(AppLocalizations.of(context)?.reminderEnableFailed ?? '');
    }
  }

  /// Scheduled notifications keep the language they were scheduled in, so
  /// they are scheduled again once the new language is saved.
  Future<void> _onLanguageChanged(
    LocaleProvider localeProvider,
    Locale locale,
  ) async {
    await localeProvider.setLocale(locale);
    try {
      final prayerModel = await PrayerProxy().getTodayPrayer();
      if (prayerModel == null) return;
      await NotificationHelper().rescheduleAll(prayerModel);
    } catch (e, st) {
      debugPrint('Rescheduling notifications failed: $e\n$st');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
