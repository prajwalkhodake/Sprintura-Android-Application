import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import '../models/user_stats_model.dart';

/// Database helper implementing the Repository pattern for SQLite operations.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'sprint_architect.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        duration INTEGER NOT NULL DEFAULT 25,
        parent_goal_id TEXT,
        parent_goal_title TEXT,
        created_at TEXT NOT NULL,
        completed_at TEXT
      )
    ''');

    // Create user_stats table
    await db.execute('''
      CREATE TABLE user_stats (
        id INTEGER PRIMARY KEY,
        total_focus_minutes INTEGER NOT NULL DEFAULT 0,
        focus_coins INTEGER NOT NULL DEFAULT 50,
        current_streak INTEGER NOT NULL DEFAULT 0,
        longest_streak INTEGER NOT NULL DEFAULT 0,
        total_sessions INTEGER NOT NULL DEFAULT 0,
        ai_uses_remaining INTEGER NOT NULL DEFAULT 5,
        last_session_date TEXT
      )
    ''');

    // Insert default user stats
    await db.insert('user_stats', UserStats().toMap());
  }

  // ========== TASK OPERATIONS ==========

  /// Insert a new task
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple tasks at once
  Future<void> insertTasks(List<Task> tasks) async {
    final db = await database;
    final batch = db.batch();
    for (final task in tasks) {
      batch.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Get all tasks, optionally filtered by completion status
  Future<List<Task>> getTasks({bool? isCompleted}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (isCompleted != null) {
      maps = await db.query(
        'tasks',
        where: 'is_completed = ?',
        whereArgs: [isCompleted ? 1 : 0],
        orderBy: 'created_at DESC',
      );
    } else {
      maps = await db.query('tasks', orderBy: 'created_at DESC');
    }

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  /// Get tasks by parent goal ID
  Future<List<Task>> getTasksByGoal(String goalId) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'parent_goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  /// Update a task (e.g., mark as completed)
  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Toggle task completion
  Future<Task> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );
    await updateTask(updatedTask);
    return updatedTask;
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all tasks for a specific goal
  Future<void> deleteTasksByGoal(String goalId) async {
    final db = await database;
    await db.delete('tasks', where: 'parent_goal_id = ?', whereArgs: [goalId]);
  }

  /// Get count of pending tasks
  Future<int> getPendingTaskCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE is_completed = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ========== USER STATS OPERATIONS ==========

  /// Get user stats
  Future<UserStats> getUserStats() async {
    final db = await database;
    final maps = await db.query('user_stats', where: 'id = ?', whereArgs: [1]);
    if (maps.isEmpty) {
      final stats = UserStats();
      await db.insert('user_stats', stats.toMap());
      return stats;
    }
    return UserStats.fromMap(maps.first);
  }

  /// Update user stats
  Future<void> updateUserStats(UserStats stats) async {
    final db = await database;
    await db.update(
      'user_stats',
      stats.toMap(),
      where: 'id = ?',
      whereArgs: [stats.id],
    );
  }

  /// Add focus minutes and coins after a completed session
  Future<UserStats> addFocusSession(int minutes) async {
    final stats = await getUserStats();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = stats.currentStreak;
    if (stats.lastSessionDate != null) {
      final lastDate = DateTime(
        stats.lastSessionDate!.year,
        stats.lastSessionDate!.month,
        stats.lastSessionDate!.day,
      );
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        newStreak += 1; // Consecutive day
      } else if (difference > 1) {
        newStreak = 1; // Streak broken
      }
      // If same day, keep current streak
    } else {
      newStreak = 1; // First session ever
    }

    final coinsEarned = (minutes * 2); // 2 coins per minute
    final updatedStats = stats.copyWith(
      totalFocusMinutes: stats.totalFocusMinutes + minutes,
      focusCoins: stats.focusCoins + coinsEarned,
      currentStreak: newStreak,
      longestStreak: newStreak > stats.longestStreak ? newStreak : stats.longestStreak,
      totalSessions: stats.totalSessions + 1,
      lastSessionDate: now,
    );

    await updateUserStats(updatedStats);
    return updatedStats;
  }

  /// Deduct focus coins (e.g., for leaving strict mode)
  Future<UserStats> deductCoins(int amount) async {
    final stats = await getUserStats();
    final newCoins = (stats.focusCoins - amount).clamp(0, 999999);
    final updatedStats = stats.copyWith(focusCoins: newCoins);
    await updateUserStats(updatedStats);
    return updatedStats;
  }

  /// Add coins (e.g., from rewarded ads)
  Future<UserStats> addCoins(int amount) async {
    final stats = await getUserStats();
    final updatedStats = stats.copyWith(focusCoins: stats.focusCoins + amount);
    await updateUserStats(updatedStats);
    return updatedStats;
  }

  /// Consume an AI use
  Future<UserStats> useAI() async {
    final stats = await getUserStats();
    if (stats.aiUsesRemaining <= 0) {
      throw Exception('No AI uses remaining. Watch an ad to earn more.');
    }
    final updatedStats = stats.copyWith(
      aiUsesRemaining: stats.aiUsesRemaining - 1,
    );
    await updateUserStats(updatedStats);
    return updatedStats;
  }

  /// Add AI uses (from rewarded ad)
  Future<UserStats> addAIUses(int amount) async {
    final stats = await getUserStats();
    final updatedStats = stats.copyWith(
      aiUsesRemaining: stats.aiUsesRemaining + amount,
    );
    await updateUserStats(updatedStats);
    return updatedStats;
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
