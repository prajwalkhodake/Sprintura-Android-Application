/// User statistics model tracking focus minutes, coins, streaks, and purchases.
class UserStats {
  final int id;
  final int totalFocusMinutes;
  final int focusCoins;
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final int aiUsesRemaining;
  final DateTime? lastSessionDate;
  final int streakShields;
  final String activeTheme; // 'default', 'sakura', 'forest'
  final String unlockedThemes; // comma-separated: 'default,sakura,forest'
  final String unlockedSounds; // comma-separated: 'none,rain,forest_stream,cosmic'
  final int adCoinsWatchedToday;
  final int adAiWatchedToday;
  final DateTime? lastAdWatchDate;

  UserStats({
    this.id = 1,
    this.totalFocusMinutes = 0,
    this.focusCoins = 50, // Start with 50 coins
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalSessions = 0,
    this.aiUsesRemaining = 5, // 5 free AI uses
    this.lastSessionDate,
    this.streakShields = 0,
    this.activeTheme = 'default',
    this.unlockedThemes = 'default',
    this.unlockedSounds = 'none',
    this.adCoinsWatchedToday = 0,
    this.adAiWatchedToday = 0,
    this.lastAdWatchDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_focus_minutes': totalFocusMinutes,
      'focus_coins': focusCoins,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_sessions': totalSessions,
      'ai_uses_remaining': aiUsesRemaining,
      'last_session_date': lastSessionDate?.toIso8601String(),
      'streak_shields': streakShields,
      'active_theme': activeTheme,
      'unlocked_themes': unlockedThemes,
      'unlocked_sounds': unlockedSounds,
      'ad_coins_watched_today': adCoinsWatchedToday,
      'ad_ai_watched_today': adAiWatchedToday,
      'last_ad_watch_date': lastAdWatchDate?.toIso8601String(),
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      id: map['id'] as int,
      totalFocusMinutes: map['total_focus_minutes'] as int,
      focusCoins: map['focus_coins'] as int,
      currentStreak: map['current_streak'] as int,
      longestStreak: map['longest_streak'] as int,
      totalSessions: map['total_sessions'] as int,
      aiUsesRemaining: map['ai_uses_remaining'] as int,
      lastSessionDate: map['last_session_date'] != null
          ? DateTime.parse(map['last_session_date'] as String)
          : null,
      streakShields: map['streak_shields'] as int? ?? 0,
      activeTheme: map['active_theme'] as String? ?? 'default',
      unlockedThemes: map['unlocked_themes'] as String? ?? 'default',
      unlockedSounds: map['unlocked_sounds'] as String? ?? 'none',
      adCoinsWatchedToday: map['ad_coins_watched_today'] as int? ?? 0,
      adAiWatchedToday: map['ad_ai_watched_today'] as int? ?? 0,
      lastAdWatchDate: map['last_ad_watch_date'] != null
          ? DateTime.parse(map['last_ad_watch_date'] as String)
          : null,
    );
  }

  UserStats copyWith({
    int? id,
    int? totalFocusMinutes,
    int? focusCoins,
    int? currentStreak,
    int? longestStreak,
    int? totalSessions,
    int? aiUsesRemaining,
    DateTime? lastSessionDate,
    int? streakShields,
    String? activeTheme,
    String? unlockedThemes,
    String? unlockedSounds,
    int? adCoinsWatchedToday,
    int? adAiWatchedToday,
    DateTime? lastAdWatchDate,
  }) {
    return UserStats(
      id: id ?? this.id,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      focusCoins: focusCoins ?? this.focusCoins,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalSessions: totalSessions ?? this.totalSessions,
      aiUsesRemaining: aiUsesRemaining ?? this.aiUsesRemaining,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      streakShields: streakShields ?? this.streakShields,
      activeTheme: activeTheme ?? this.activeTheme,
      unlockedThemes: unlockedThemes ?? this.unlockedThemes,
      unlockedSounds: unlockedSounds ?? this.unlockedSounds,
      adCoinsWatchedToday: adCoinsWatchedToday ?? this.adCoinsWatchedToday,
      adAiWatchedToday: adAiWatchedToday ?? this.adAiWatchedToday,
      lastAdWatchDate: lastAdWatchDate ?? this.lastAdWatchDate,
    );
  }

  /// Calculate hours of focus from total minutes
  String get focusHours {
    final hours = totalFocusMinutes ~/ 60;
    final minutes = totalFocusMinutes % 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  /// Check if a theme is unlocked
  bool isThemeUnlocked(String themeId) {
    return unlockedThemes.split(',').contains(themeId);
  }

  /// Check if a sound is unlocked
  bool isSoundUnlocked(String soundId) {
    return unlockedSounds.split(',').contains(soundId);
  }

  /// Get list of unlocked theme IDs
  List<String> get unlockedThemeList => unlockedThemes.split(',');

  /// Get list of unlocked sound IDs
  List<String> get unlockedSoundList => unlockedSounds.split(',');

  // ========== DAILY AD TRACKING HELPERS ==========

  /// Whether today is a new day compared to lastAdWatchDate
  bool get isNewDay {
    if (lastAdWatchDate == null) return true;
    final now = DateTime.now();
    return now.year != lastAdWatchDate!.year ||
        now.month != lastAdWatchDate!.month ||
        now.day != lastAdWatchDate!.day;
  }

  /// Effective coin ads watched today (resets on new day)
  int get effectiveCoinsWatched => isNewDay ? 0 : adCoinsWatchedToday;

  /// Effective AI ads watched today (resets on new day)
  int get effectiveAiWatched => isNewDay ? 0 : adAiWatchedToday;

  /// Whether the user can still watch a coin reward ad today (limit: 5)
  bool get canWatchCoinAd => effectiveCoinsWatched < 5;

  /// Whether the user can still watch an AI reward ad today (limit: 3)
  bool get canWatchAiAd => effectiveAiWatched < 3;

  /// Remaining coin ad watches today
  int get remainingCoinAds => (5 - effectiveCoinsWatched).clamp(0, 5);

  /// Remaining AI ad watches today
  int get remainingAiAds => (3 - effectiveAiWatched).clamp(0, 3);
}
