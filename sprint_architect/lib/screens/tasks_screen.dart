import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../models/task_model.dart';

/// Tasks screen — displays micro-tasks with haptic feedback on completion.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final tc = AppTheme.getThemeColors(provider.activeTheme);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [tc.background1, tc.background2],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Tasks',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: tc.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tc.accent.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusRound),
                        ),
                        child: Text(
                          '${provider.pendingTasks.length} pending',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: tc.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tab bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tc.card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: tc.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: tc.accent,
                      unselectedLabelColor: tc.textMuted,
                      labelStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.pending_actions_rounded,
                                  size: 18),
                              const SizedBox(width: 8),
                              Text('Active (${provider.pendingTasks.length})'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  size: 18),
                              const SizedBox(width: 8),
                              Text(
                                  'Done (${provider.completedTasks.length})'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Task list
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTaskList(provider.pendingTasks, provider, tc, false),
                      _buildTaskList(provider.completedTasks, provider, tc, true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskList(
      List<Task> tasks, AppProvider provider, ThemeColors tc, bool isCompleted) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted
                  ? Icons.emoji_events_rounded
                  : Icons.inbox_rounded,
              size: 64,
              color: tc.textDim,
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted
                  ? 'No completed tasks yet'
                  : 'No pending tasks',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: tc.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCompleted
                  ? 'Complete tasks to see them here'
                  : 'Use Brain Dump to generate tasks',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: tc.textDim,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskItem(task, provider, tc, index)
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 50 * index),
              duration: 300.ms,
            )
            .slideX(
              begin: 0.05,
              end: 0,
              delay: Duration(milliseconds: 50 * index),
              duration: 300.ms,
            );
      },
    );
  }

  Widget _buildTaskItem(Task task, AppProvider provider, ThemeColors tc, int index) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.lightImpact();
        provider.deleteTask(task);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tc.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: task.isCompleted
                ? tc.accent.withValues(alpha: 0.2)
                : tc.divider.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                provider.toggleTask(task);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted
                      ? tc.accent
                      : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? tc.accent
                        : tc.textMuted,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? Icon(Icons.check, size: 14, color: tc.background1)
                    : null,
              ),
            ),
            const SizedBox(width: 14),

            // Task info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: task.isCompleted
                          ? tc.textMuted
                          : tc.textPrimary,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: tc.textDim,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task.duration} min',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: tc.textDim,
                        ),
                      ),
                      if (task.parentGoalTitle != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.flag_outlined,
                          size: 13,
                          color: tc.textDim,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            task.parentGoalTitle!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: tc.textDim,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
