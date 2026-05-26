// Data models for the remote configuration and in-app notification system.
// The backend serves a JSON config that the app fetches on startup.
// This file defines the Dart data classes that parse that JSON.

/// Top-level remote config received from the Vercel backend.
class RemoteConfig {
  final String latestVersion;
  final String minVersion;
  final String updateUrl;
  final List<AppNotification> notifications;
  final Map<String, bool> featureFlags;
  final String motd;

  const RemoteConfig({
    this.latestVersion = '1.0.0',
    this.minVersion = '1.0.0',
    this.updateUrl = '',
    this.notifications = const [],
    this.featureFlags = const {},
    this.motd = '',
  });

  factory RemoteConfig.fromJson(Map<String, dynamic> json) {
    return RemoteConfig(
      latestVersion: json['latest_version'] as String? ?? '1.0.0',
      minVersion: json['min_version'] as String? ?? '1.0.0',
      updateUrl: json['update_url'] as String? ?? '',
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
              .toList() ??
          [],
      featureFlags: (json['feature_flags'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as bool)) ??
          {},
      motd: json['motd'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'latest_version': latestVersion,
        'min_version': minVersion,
        'update_url': updateUrl,
        'notifications': notifications.map((n) => n.toJson()).toList(),
        'feature_flags': featureFlags,
        'motd': motd,
      };

  /// Compare two semantic version strings (e.g. "1.2.3" vs "1.3.0").
  /// Returns negative if a < b, zero if equal, positive if a > b.
  static int compareVersions(String a, String b) {
    final aParts = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final bParts = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad to same length
    while (aParts.length < 3) {
      aParts.add(0);
    }
    while (bParts.length < 3) {
      bParts.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (aParts[i] < bParts[i]) return -1;
      if (aParts[i] > bParts[i]) return 1;
    }
    return 0;
  }
}

/// Represents a single in-app notification that can be a popup, banner,
/// or force-update dialog.
class AppNotification {
  final String id;
  final String type; // 'popup', 'banner', 'force_update'
  final String title;
  final String message;
  final String ctaText;
  final String ctaAction; // 'shop', 'url', 'dismiss', 'update'
  final String ctaUrl;
  final String priority; // 'low', 'normal', 'high', 'critical'
  final String startDate;
  final String endDate;
  final bool dismissible;

  const AppNotification({
    required this.id,
    this.type = 'popup',
    this.title = '',
    this.message = '',
    this.ctaText = '',
    this.ctaAction = 'dismiss',
    this.ctaUrl = '',
    this.priority = 'normal',
    this.startDate = '',
    this.endDate = '',
    this.dismissible = true,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'popup',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      ctaText: json['cta_text'] as String? ?? '',
      ctaAction: json['cta_action'] as String? ?? 'dismiss',
      ctaUrl: json['cta_url'] as String? ?? '',
      priority: json['priority'] as String? ?? 'normal',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      dismissible: json['dismissible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'message': message,
        'cta_text': ctaText,
        'cta_action': ctaAction,
        'cta_url': ctaUrl,
        'priority': priority,
        'start_date': startDate,
        'end_date': endDate,
        'dismissible': dismissible,
      };

  bool get isPopup => type == 'popup';
  bool get isBanner => type == 'banner';
  bool get isForceUpdate => type == 'force_update';
}
