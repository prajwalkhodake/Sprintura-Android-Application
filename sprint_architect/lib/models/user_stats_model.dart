/// User statistics model tracking focus minutes, coins, and streaks.
class UserStats {
  final int id;
  final int totalFocusMinutes;
  final int focusCoins;
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final int aiUsesRemaining;
  final DateTime? lastSessionDate;

  UserStats({
    this.id = 1,
    this.totalFocusMinutes = 0,
    this.focusCoins = 50, // Start with 50 coins
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalSessions = 0,
    this.aiUsesRemaining = 5, // 5 free AI uses
    this.lastSessionDate,
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
    );
  }

  /// Calculate hours of focus from total minutes
  String get focusHours {
    final hours = totalFocusMinutes ~/ 60;
    final minutes = totalFocusMinutes % 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }
}
