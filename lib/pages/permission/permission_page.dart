import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/components/fade_page_route.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/prayer_sync_helper.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/home/home_city_picker_dialog.dart';
import 'package:deenly/pages/main_page.dart';
import 'package:deenly/pages/permission/permission_location_step_widget.dart';
import 'package:deenly/pages/permission/permission_notification_step_widget.dart';
import 'package:deenly/proxys/location_proxy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

enum _PermissionStep { location, notification }

/// Onboarding page that explains and requests the location and
/// notification permissions before entering the app.
class PermissionPage extends StatefulWidget {
  final bool askLocation;
  final bool askNotification;

  const PermissionPage({
    super.key,
    required this.askLocation,
    required this.askNotification,
  });

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage>
    with WidgetsBindingObserver {
  final LocationProxy _locationProxy = LocationProxy();
  final NotificationHelper _notificationHelper = NotificationHelper();

  late _PermissionStep _step = widget.askLocation
      ? _PermissionStep.location
      : _PermissionStep.notification;
  LocationStepState _locationState = LocationStepState.initial;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_step == _PermissionStep.location) _loadLocationState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Picks up a permission granted from the system settings page.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (_step != _PermissionStep.location || _isBusy) return;
    _recheckLocation();
  }

  Future<void> _loadLocationState() async {
    final permission = await _locationProxy.checkPermission();
    if (!mounted || permission != LocationPermission.deniedForever) return;
    setState(() => _locationState = LocationStepState.blocked);
  }

  Future<void> _recheckLocation() async {
    if (await _locationProxy.hasPermission()) {
      _onLocationReady();
    }
  }

  Future<void> _requestLocation() async {
    setState(() => _isBusy = true);
    final granted = await _locationProxy.requestPermission();
    if (!mounted) return;
    setState(() => _isBusy = false);

    switch (granted) {
      case true:
        _onLocationReady();
      case false:
        setState(() => _locationState = LocationStepState.denied);
      case null:
        setState(() => _locationState = LocationStepState.blocked);
    }
  }

  Future<void> _chooseCity() async {
    final cityName = await showDialog<String>(
      context: context,
      builder: (_) => const HomeCityPickerDialog(),
    );
    if (cityName == null || !mounted) return;

    setState(() => _isBusy = true);
    final success = await PrayerSyncHelper().setManualLocation(cityName);
    if (!mounted) return;
    setState(() => _isBusy = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.cityNotFound ?? ''),
        ),
      );
      return;
    }
    _onLocationReady();
  }

  void _onLocationReady() {
    if (!mounted) return;
    if (widget.askNotification) {
      setState(() => _step = _PermissionStep.notification);
    } else {
      _goToMain();
    }
  }

  Future<void> _requestNotification() async {
    final drawerProvider = context.read<DrawerProvider>();
    setState(() => _isBusy = true);
    final granted = await _notificationHelper.requestPermission();
    if (granted) await drawerProvider.enableAllNotifications();
    await _notificationHelper.markPermissionAsked();
    _goToMain();
  }

  Future<void> _skipNotification() async {
    setState(() => _isBusy = true);
    await _notificationHelper.markPermissionAsked();
    _goToMain();
  }

  void _goToMain() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      FadePageRoute(builder: (context) => const MainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final step = switch (_step) {
      _PermissionStep.location => PermissionLocationStepWidget(
        key: const ValueKey(_PermissionStep.location),
        state: _locationState,
        isBusy: _isBusy,
        onAllow: _requestLocation,
        onOpenSettings: _locationProxy.openAppSettings,
        onChooseCity: _chooseCity,
      ),
      _PermissionStep.notification => PermissionNotificationStepWidget(
        key: const ValueKey(_PermissionStep.notification),
        isBusy: _isBusy,
        onAllow: _requestNotification,
        onSkip: _skipNotification,
      ),
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: step,
          ),
        ),
      ),
    );
  }
}
