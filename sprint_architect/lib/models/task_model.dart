/// Task model representing a micro-task generated from a brain dump.
class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final int duration; // in minutes
  final String? parentGoalId;
  final String? parentGoalTitle;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.duration = 25,
    this.parentGoalId,
    this.parentGoalTitle,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
      'duration': duration,
      'parent_goal_id': parentGoalId,
      'parent_goal_title': parentGoalTitle,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
      duration: map['duration'] as int,
      parentGoalId: map['parent_goal_id'] as String?,
      parentGoalTitle: map['parent_goal_title'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? duration,
    String? parentGoalId,
    String? parentGoalTitle,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      duration: duration ?? this.duration,
      parentGoalId: parentGoalId ?? this.parentGoalId,
      parentGoalTitle: parentGoalTitle ?? this.parentGoalTitle,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
