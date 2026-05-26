import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../models/user_stats_model.dart';
import '../models/remote_config_model.dart';
import '../services/ai_service.dart';
import '../services/ad_service.dart';
import '../services/remote_config_service.dart';

/// Main application state provider managing tasks, stats, timer, ads, and shop.
class AppProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final AIService _aiService = AIService();
  final AdService _adService = AdService();
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  // ========== STATE ==========
  List<Task> _tasks = [];
  UserStats _stats = UserStats();
  bool _isLoading = false;
  bool _isDeconstructing = false;
  String? _errorMessage;
  String? _successMessage;

  // Timer state
  int _timerDuration = 25 * 60; // 25 minutes in seconds
  int _timerRemaining = 25 * 60;
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;
  Timer? _timer;
  String? _currentTimerTaskId;

  // Strict mode
  bool _strictMode = false;
  bool _hasLeftApp = false;

  // Active ambient sound for timer
  String _activeSound = 'none';

  // ========== GETTERS ==========
  List<Task> get tasks => _tasks;
  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  UserStats get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isDeconstructing => _isDeconstructing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  int get timerDuration => _timerDuration;
  int get timerRemaining => _timerRemaining;
  bool get isTimerRunning => _isTimerRunning;
  bool get isTimerPaused => _isTimerPaused;
  String? get currentTimerTaskId => _currentTimerTaskId;

  bool get strictMode => _strictMode;
  bool get hasLeftApp => _hasLeftApp;
  AdService get adService => _adService;
  RemoteConfigService get remoteConfigService => _remoteConfigService;
  String get activeSound => _activeSound;
  String get activeTheme => _stats.activeTheme;

  // Remote config getters
  RemoteConfig get remoteConfig => _remoteConfigService.config;
  bool get needsForceUpdate => _remoteConfigService.needsForceUpdate;
  bool get hasNewVersion => _remoteConfigService.hasNewVersion;
  List<AppNotification> get activePopups => _remoteConfigService.activePopups;
  List<AppNotification> get activeBanners => _remoteConfigService.activeBanners;
  String get motd => _remoteConfigService.motd;
  bool get isRemoteConfigLoaded => _remoteConfigService.isLoaded;

  double get timerProgress {
    if (_timerDuration == 0) return 0;
    return 1.0 - (_timerRemaining / _timerDuration);
  }

  String get timerDisplay {
    final minutes = _timerRemaining ~/ 60;
    final seconds = _timerRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ========== INITIALIZATION ==========
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = await _db.getUserStats();
      _tasks = await _db.getTasks();

      // Load preferences
      final prefs = await SharedPreferences.getInstance();
      _strictMode = prefs.getBool('strict_mode') ?? false;
      _activeSound = prefs.getString('active_sound') ?? 'none';

      // Pre-load ads
      _adService.loadInterstitialAd();
      _adService.loadRewardedAd();

      // Fetch remote config (non-blocking, falls back to cache)
      await _remoteConfigService.fetchConfig();
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ========== AI TASK DECONSTRUCTION ==========
  Future<void> deconstructGoal(String brainDump) async {
    if (brainDump.trim().isEmpty) return;

    _isDeconstructing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check AI uses
      if (_stats.aiUsesRemaining <= 0) {
        _errorMessage = 'No AI uses remaining. Watch an ad or buy a refill!';
        _isDeconstructing = false;
        notifyListeners();
        return;
      }

      // Consume an AI use
      _stats = await _db.useAI();

      // Get tasks from AI
      final newTasks = await _aiService.deconstructGoal(brainDump);

      // Save to database
      await _db.insertTasks(newTasks);

      // Refresh task list
      _tasks = await _db.getTasks();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isDeconstructing = false;
    notifyListeners();
  }

  // ========== TASK OPERATIONS ==========
  Future<void> toggleTask(Task task) async {
    final updatedTask = await _db.toggleTaskCompletion(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  Future<void> deleteTask(Task task) async {
    await _db.deleteTask(task.id);
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();
  }

  Future<void> deleteGoalTasks(String goalId) async {
    await _db.deleteTasksByGoal(goalId);
    _tasks.removeWhere((t) => t.parentGoalId == goalId);
    notifyListeners();
  }

  Future<void> refreshTasks() async {
    _tasks = await _db.getTasks();
    notifyListeners();
  }

  // ========== TIMER OPERATIONS ==========
  void setTimerDuration(int minutes) {
    _timerDuration = minutes * 60;
    _timerRemaining = _timerDuration;
    notifyListeners();
  }

  void startTimer({String? taskId}) {
    _currentTimerTaskId = taskId;
    _isTimerRunning = true;
    _isTimerPaused = false;
    _hasLeftApp = false;

    // Load interstitial ad when timer starts
    _adService.loadInterstitialAd();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerRemaining > 0) {
        _timerRemaining--;
        notifyListeners();
      } else {
        _onTimerComplete();
      }
    });

    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    _isTimerPaused = true;
    notifyListeners();
  }

  void resumeTimer() {
    _isTimerPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerRemaining > 0) {
        _timerRemaining--;
        notifyListeners();
      } else {
        _onTimerComplete();
      }
    });
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _timerRemaining = _timerDuration;
    _isTimerRunning = false;
    _isTimerPaused = false;
    _currentTimerTaskId = null;
    _hasLeftApp = false;
    notifyListeners();
  }

  Future<void> _onTimerComplete() async {
    _timer?.cancel();
    _isTimerRunning = false;
    _isTimerPaused = false;

    // Add focus session
    final minutes = _timerDuration ~/ 60;
    _stats = await _db.addFocusSession(minutes);

    // Show interstitial ad after successful session
    if (_adService.isInterstitialAdReady) {
      await _adService.showInterstitialAd();
    }

    // Mark task as completed if there was one
    if (_currentTimerTaskId != null) {
      final taskIndex = _tasks.indexWhere((t) => t.id == _currentTimerTaskId);
      if (taskIndex != -1) {
        final updatedTask = await _db.toggleTaskCompletion(_tasks[taskIndex]);
        _tasks[taskIndex] = updatedTask;
      }
    }

    _currentTimerTaskId = null;
    _timerRemaining = _timerDuration;
    notifyListeners();
  }

  // ========== STRICT MODE ==========
  Future<void> setStrictMode(bool value) async {
    _strictMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('strict_mode', value);
    notifyListeners();
  }

  /// Called when the app loses focus during a timer session
  Future<void> onAppBackgrounded() async {
    if (_isTimerRunning && _strictMode && !_isTimerPaused) {
      _hasLeftApp = true;
      _stats = await _db.deductCoins(10);
      notifyListeners();
    }
  }

  // ========== AD REWARDS ==========
  Future<void> watchAdForCoins() async {
    if (!_stats.canWatchCoinAd) {
      _errorMessage = 'Daily limit reached (5/5). Come back tomorrow!';
      notifyListeners();
      return;
    }

    final reward = await _adService.showRewardedAd();
    if (reward > 0) {
      // Ad was watched and reward earned — update database
      _stats = await _db.addCoinsFromAd(25);
      _successMessage = '+25 Coins earned!';
      notifyListeners();
    } else {
      _errorMessage = 'Ad not available right now. Try again later.';
      notifyListeners();
    }
  }

  Future<void> watchAdForAIUses() async {
    if (!_stats.canWatchAiAd) {
      _errorMessage = 'Daily AI limit reached (3/3). Come back tomorrow!';
      notifyListeners();
      return;
    }

    final reward = await _adService.showRewardedAd();
    if (reward > 0) {
      // Ad was watched and reward earned — update database
      _stats = await _db.addAIUsesFromAd(3);
      _successMessage = '+3 AI Uses earned!';
      notifyListeners();
    } else {
      _errorMessage = 'Ad not available right now. Try again later.';
      notifyListeners();
    }
  }

  // ========== COIN SHOP PURCHASES ==========

  /// Buy AI refill with coins (100 coins → +5 AI uses)
  Future<bool> purchaseAIRefill() async {
    try {
      _stats = await _db.buyAIRefill();
      _successMessage = '🧠 +5 AI Uses unlocked!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Buy streak shield (300 coins → +1 shield)
  Future<bool> purchaseStreakShield() async {
    try {
      _stats = await _db.buyStreakShield();
      _successMessage = '🛡️ Streak Shield activated!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Buy a premium theme (1000 coins)
  Future<bool> purchaseTheme(String themeId) async {
    try {
      _stats = await _db.buyTheme(themeId);
      _successMessage = '🎨 Theme unlocked and applied!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Switch active theme (free if already unlocked)
  Future<void> switchTheme(String themeId) async {
    try {
      _stats = await _db.setActiveTheme(themeId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Buy an ambient sound (500 coins)
  Future<bool> purchaseSound(String soundId) async {
    try {
      _stats = await _db.buySound(soundId);
      _successMessage = '🎵 Ambient sound unlocked!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Set active ambient sound
  Future<void> setActiveSound(String soundId) async {
    _activeSound = soundId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_sound', soundId);
    notifyListeners();
  }

  // ========== REMOTE CONFIG ==========

  /// Dismiss a remote notification so it won't show again.
  Future<void> dismissNotification(String notificationId) async {
    await _remoteConfigService.dismissNotification(notificationId);
    notifyListeners();
  }

  /// Check if a feature is enabled via remote feature flags.
  bool isFeatureEnabled(String flagName) {
    return _remoteConfigService.isFeatureEnabled(flagName);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  /// Get unique goals from tasks
  List<String> get uniqueGoalIds {
    final goalIds = <String>{};
    for (final task in _tasks) {
      if (task.parentGoalId != null) {
        goalIds.add(task.parentGoalId!);
      }
    }
    return goalIds.toList();
  }

  /// Get tasks grouped by goal
  Map<String, List<Task>> get tasksByGoal {
    final grouped = <String, List<Task>>{};
    for (final task in _tasks) {
      final goalId = task.parentGoalId ?? 'ungrouped';
      grouped.putIfAbsent(goalId, () => []);
      grouped[goalId]!.add(task);
    }
    return grouped;
  }

  /// Get completion percentage for a goal
  double goalCompletionPercent(String goalId) {
    final goalTasks = _tasks.where((t) => t.parentGoalId == goalId).toList();
    if (goalTasks.isEmpty) return 0;
    final completed = goalTasks.where((t) => t.isCompleted).length;
    return completed / goalTasks.length;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _adService.dispose();
    super.dispose();
  }
}
