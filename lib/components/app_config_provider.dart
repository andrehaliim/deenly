import 'package:deenly/models/app_config_model.dart';
import 'package:deenly/proxys/app_config_proxy.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConfigProvider extends ChangeNotifier {
  final AppConfigProxy _proxy = AppConfigProxy();

  AppConfigModel? _config;
  String? _appVersion;

  AppConfigModel? get config => _config;

  bool get requiresUpdate {
    final config = _config;
    final appVersion = _appVersion;
    if (config == null || appVersion == null) return false;
    return config.requiresUpdate(appVersion);
  }

  /// Applies the cached (or bundled) config first, then replaces it with
  /// the remote one when the device is online.
  Future<void> load() async {
    try {
      _appVersion = (await PackageInfo.fromPlatform()).version;
    } catch (e) {
      debugPrint('Reading app version failed: $e');
    }

    try {
      _config = await _proxy.getLocal();
      notifyListeners();
    } catch (e, st) {
      debugPrint('Loading local app config failed: $e\n$st');
    }

    try {
      _config = await _proxy.fetchRemote();
      notifyListeners();
    } catch (e) {
      debugPrint('Fetching remote app config failed: $e');
    }
  }
}
