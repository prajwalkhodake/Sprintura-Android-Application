import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import 'package:uuid/uuid.dart';

/// Service for communicating with the Flask AI backend.
class AIService {
  // Update this URL when deploying to Vercel
  static const String _baseUrl = 'https://sprint-architect-api.vercel.app';
  static const String _localUrl = 'http://10.0.2.2:5000'; // Android emulator localhost
  
  final bool useLocal;
  final Uuid _uuid = const Uuid();

  AIService({this.useLocal = false});

  String get baseUrl => useLocal ? _localUrl : _baseUrl;

  /// Send a brain dump to the AI backend and receive micro-tasks.
  /// Falls back to local task generation if the server is unavailable.
  Future<List<Task>> deconstructGoal(String brainDump) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/deconstruct'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'brain_dump': brainDump}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final goalId = _uuid.v4();
        final tasks = (data['tasks'] as List).map((taskData) {
          return Task(
            id: _uuid.v4(),
            title: taskData['title'] as String,
            duration: taskData['duration'] as int? ?? 25,
            parentGoalId: goalId,
            parentGoalTitle: brainDump,
          );
        }).toList();
        return tasks;
      } else {
        // Fallback to local generation
        return _generateLocalTasks(brainDump);
      }
    } catch (e) {
      // Fallback to local generation when server is unavailable
      return _generateLocalTasks(brainDump);
    }
  }

  /// Generate tasks locally as a fallback when the AI server is unavailable.
  /// Uses simple heuristics to break down goals into actionable steps.
  List<Task> _generateLocalTasks(String brainDump) {
    final goalId = _uuid.v4();
    final isLearning = brainDump.toLowerCase().contains('learn') ||
        brainDump.toLowerCase().contains('study') ||
        brainDump.toLowerCase().contains('course');
    final isBuilding = brainDump.toLowerCase().contains('build') ||
        brainDump.toLowerCase().contains('create') ||
        brainDump.toLowerCase().contains('develop') ||
        brainDump.toLowerCase().contains('make');
    final isWriting = brainDump.toLowerCase().contains('write') ||
        brainDump.toLowerCase().contains('blog') ||
        brainDump.toLowerCase().contains('essay') ||
        brainDump.toLowerCase().contains('article');
    final isFitness = brainDump.toLowerCase().contains('workout') ||
        brainDump.toLowerCase().contains('exercise') ||
        brainDump.toLowerCase().contains('run') ||
        brainDump.toLowerCase().contains('gym');

    List<Map<String, dynamic>> taskTemplates;

    if (isLearning) {
      taskTemplates = [
        {'title': 'Research and gather resources about ${_extractTopic(brainDump)}', 'duration': 15},
        {'title': 'Review fundamentals and take notes', 'duration': 25},
        {'title': 'Practice with hands-on exercises', 'duration': 25},
        {'title': 'Summarize key learnings and create flashcards', 'duration': 15},
        {'title': 'Review and self-test your understanding', 'duration': 10},
      ];
    } else if (isBuilding) {
      taskTemplates = [
        {'title': 'Define the project scope and requirements', 'duration': 15},
        {'title': 'Set up the development environment', 'duration': 20},
        {'title': 'Build the core functionality', 'duration': 25},
        {'title': 'Add finishing touches and polish', 'duration': 20},
        {'title': 'Test and review the final output', 'duration': 15},
      ];
    } else if (isWriting) {
      taskTemplates = [
        {'title': 'Brainstorm ideas and create an outline', 'duration': 15},
        {'title': 'Write the first draft', 'duration': 25},
        {'title': 'Review and revise content', 'duration': 20},
        {'title': 'Edit for grammar and clarity', 'duration': 15},
        {'title': 'Final proofread and formatting', 'duration': 10},
      ];
    } else if (isFitness) {
      taskTemplates = [
        {'title': 'Warm up with dynamic stretches', 'duration': 10},
        {'title': 'Complete the main workout', 'duration': 25},
        {'title': 'Cool down and stretch', 'duration': 10},
        {'title': 'Log progress and plan next session', 'duration': 5},
      ];
    } else {
      taskTemplates = [
        {'title': 'Break down "$brainDump" into smaller steps', 'duration': 10},
        {'title': 'Start with the most important sub-task', 'duration': 25},
        {'title': 'Continue with the next priority item', 'duration': 25},
        {'title': 'Review progress and wrap up', 'duration': 15},
      ];
    }

    return taskTemplates.map((template) {
      return Task(
        id: _uuid.v4(),
        title: template['title'] as String,
        duration: template['duration'] as int,
        parentGoalId: goalId,
        parentGoalTitle: brainDump,
      );
    }).toList();
  }

  String _extractTopic(String brainDump) {
    // Simple extraction: remove common verbs and return the rest
    final cleaned = brainDump
        .replaceAll(RegExp(r'\b(learn|study|master|understand|explore|practice)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isNotEmpty ? cleaned : brainDump;
  }
}
