import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/proxys/location_proxy.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Asks for the notification permission before a reminder is turned on.
class NotificationPermissionPrompt {
  /// Returns true when notifications are allowed, showing the system
  /// prompt first when they are not. Once Android stops showing that
  /// prompt, a snackbar sends the user to the app settings instead.
  static Future<bool> ensure(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final drawerProvider = context.read<DrawerProvider>();
    final notificationHelper = NotificationHelper();

    final isGranted =
        await notificationHelper.isPermissionGranted() ||
        await notificationHelper.requestPermission();

    /// Brings back the saved reminders when the permission was just given.
    await drawerProvider.refreshNotificationPermission();
    if (isGranted) return true;

    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n?.notificationPermissionBlocked ?? ''),
        action: SnackBarAction(
          label: l10n?.notificationOpenSettings ?? '',
          onPressed: LocationProxy().openAppSettings,
        ),
      ),
    );
    return false;
  }
}
