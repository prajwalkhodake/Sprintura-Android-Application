import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/remote_config_model.dart';

/// Fetches remote configuration from the Vercel backend on app startup.
///
/// Features:
/// - Fetches /api/config and parses into [RemoteConfig]
/// - Caches the last successful response in SharedPreferences
/// - Tracks dismissed notification IDs so users don't see the same popup twice
/// - Gracefully falls back to cached or default config when offline
class RemoteConfigService {
  static const String _baseUrl = 'https://backend-two-orpin-81.vercel.app';
  static const String _cacheKey = 'remote_config_cache';
  static const String _dismissedKey = 'dismissed_notification_ids';

  /// Current app version — update this when you release a new version.
  static const String currentAppVersion = '1.0.0';

  RemoteConfig _config = const RemoteConfig();
  Set<String> _dismissedIds = {};
  bool _isLoaded = false;

  RemoteConfig get config => _config;
  bool get isLoaded => _isLoaded;

  /// Fetch the remote config. Falls back to cache if network fails.
  Future<RemoteConfig> fetchConfig() async {
    final prefs = await SharedPreferences.getInstance();

    // Load dismissed notification IDs from local storage
    final dismissedList = prefs.getStringList(_dismissedKey) ?? [];
    _dismissedIds = dismissedList.toSet();

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/config'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _config = RemoteConfig.fromJson(data);

        // Cache the successful response
        await prefs.setString(_cacheKey, response.body);
      } else {
        // Fall back to cache
        _config = _loadFromCache(prefs);
      }
    } catch (e) {
      // Network error — fall back to cache
      _config = _loadFromCache(prefs);
    }

    _isLoaded = true;
    return _config;
  }

  /// Load config from SharedPreferences cache.
  RemoteConfig _loadFromCache(SharedPreferences prefs) {
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        return RemoteConfig.fromJson(data);
      } catch (_) {
        return const RemoteConfig();
      }
    }
    return const RemoteConfig();
  }

  // ========== VERSION CHECKS ==========

  /// True if the current app version is below the minimum required version.
  /// This means a force-update dialog should be shown.
  bool get needsForceUpdate {
    return RemoteConfig.compareVersions(
            currentAppVersion, _config.minVersion) <
        0;
  }

  /// True if a newer version is available (but not forced).
  bool get hasNewVersion {
    return RemoteConfig.compareVersions(
            currentAppVersion, _config.latestVersion) <
        0;
  }

  // ========== NOTIFICATION MANAGEMENT ==========

  /// Get notifications that haven't been dismissed yet.
  List<AppNotification> get activeNotifications {
    return _config.notifications
        .where((n) => !_dismissedIds.contains(n.id))
        .toList();
  }

  /// Get only popup-type notifications that haven't been dismissed.
  List<AppNotification> get activePopups {
    return activeNotifications.where((n) => n.isPopup).toList();
  }

  /// Get only banner-type notifications that haven't been dismissed.
  List<AppNotification> get activeBanners {
    return activeNotifications.where((n) => n.isBanner).toList();
  }

  /// Mark a notification as dismissed so it won't appear again.
  Future<void> dismissNotification(String notificationId) async {
    _dismissedIds.add(notificationId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dismissedKey, _dismissedIds.toList());
  }

  /// Check if a notification has been dismissed.
  bool isDismissed(String notificationId) {
    return _dismissedIds.contains(notificationId);
  }

  // ========== FEATURE FLAGS ==========

  /// Check if a feature is enabled. Defaults to true if flag is not present.
  bool isFeatureEnabled(String flagName) {
    return _config.featureFlags[flagName] ?? true;
  }

  /// Message of the day.
  String get motd => _config.motd;
}
