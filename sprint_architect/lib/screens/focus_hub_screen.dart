import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/in_app_notification_widget.dart';

/// Focus Hub Screen — the main brain dump entry point.
class FocusHubScreen extends StatefulWidget {
  const FocusHubScreen({super.key});

  @override
  State<FocusHubScreen> createState() => _FocusHubScreenState();
}

class _FocusHubScreenState extends State<FocusHubScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _brainDumpController = TextEditingController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _brainDumpController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _submitBrainDump() {
    final text = _brainDumpController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.mediumImpact();
    context.read<AppProvider>().deconstructGoal(text);
    _brainDumpController.clear();
    FocusScope.of(context).unfocus();
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
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreetingHeader(provider, tc),
                        const SizedBox(height: 24),
                        _buildStatsRow(provider, tc),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ── Remote Banners ──
                // Update available banner
                if (provider.hasNewVersion)
                  SliverToBoxAdapter(
                    child: UpdateAvailableBanner(
                      latestVersion: provider.remoteConfig.latestVersion,
                      updateUrl: provider.remoteConfig.updateUrl,
                      tc: tc,
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
                  ),

                // MOTD banner
                if (provider.motd.isNotEmpty)
                  SliverToBoxAdapter(
                    child: NotificationBanner(
                      title: '',
                      message: provider.motd,
                      tc: tc,
                      icon: Icons.lightbulb_outline_rounded,
                      accentColor: AppTheme.warningAmber,
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
                  ),

                // Remote notification banners
                ...provider.activeBanners.map((banner) {
                  return SliverToBoxAdapter(
                    child: NotificationBanner(
                      title: banner.title,
                      message: banner.message,
                      tc: tc,
                      onDismiss: () => provider.dismissNotification(banner.id),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
                  );
                }),

                // ── Brain Dump Card ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBrainDumpCard(provider, tc),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Deconstructing animation
                if (provider.isDeconstructing)
                  SliverToBoxAdapter(
                    child: _buildDeconstructingAnimation(tc),
                  ),

                // Error message
                if (provider.errorMessage != null)
                  SliverToBoxAdapter(
                    child: _buildErrorMessage(provider, tc),
                  ),

                // Recent goals
                if (provider.tasksByGoal.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                      child: Text(
                        'Your Sprints',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: tc.textPrimary),
                      ),
                    ),
                  ),

                // Goal cards
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final goalId = provider.tasksByGoal.keys.elementAt(index);
                      final tasks = provider.tasksByGoal[goalId]!;
                      final goalTitle = tasks.first.parentGoalTitle ?? 'Goal';
                      final completedCount = tasks.where((t) => t.isCompleted).length;
                      final progress = completedCount / tasks.length;

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: _buildGoalCard(
                          goalTitle,
                          tasks.length,
                          completedCount,
                          progress,
                          goalId,
                          provider,
                          tc,
                        ),
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 100 * index),
                            duration: 400.ms,
                          )
                          .slideX(
                            begin: 0.05,
                            end: 0,
                            delay: Duration(milliseconds: 100 * index),
                            duration: 400.ms,
                          );
                    },
                    childCount: provider.tasksByGoal.length,
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreetingHeader(AppProvider provider, ThemeColors tc) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_cloudy_rounded;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nights_stay_rounded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(greetingIcon, color: tc.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              greeting,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: tc.accent,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Focus Hub',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: tc.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildStatsRow(AppProvider provider, ThemeColors tc) {
    return Row(
      children: [
        _buildStatChip(
          Icons.local_fire_department_rounded,
          '${provider.stats.currentStreak}',
          'Streak',
          AppTheme.warningAmber,
          tc,
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          Icons.monetization_on_rounded,
          '${provider.stats.focusCoins}',
          'Coins',
          const Color(0xFFFFD700),
          tc,
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          Icons.schedule_rounded,
          provider.stats.focusHours,
          'Focus',
          tc.accent,
          tc,
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          Icons.auto_awesome_rounded,
          '${provider.stats.aiUsesRemaining}',
          'AI Uses',
          const Color(0xFFB388FF),
          tc,
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.1, end: 0, delay: 200.ms);
  }

  Widget _buildStatChip(
      IconData icon, String value, String label, Color color, ThemeColors tc) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: tc.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: tc.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: tc.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrainDumpCard(AppProvider provider, ThemeColors tc) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tc.card, tc.background2],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: tc.accent.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tc.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  color: tc.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Brain Dump',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: tc.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "What's your big goal today? I'll break it into micro-tasks.",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: tc.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _brainDumpController,
            maxLines: 3,
            minLines: 2,
            style: GoogleFonts.inter(
              color: tc.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText:
                  'e.g. "Learn Flutter state management" or "Build a landing page"',
              hintStyle: GoogleFonts.inter(
                color: tc.textDim,
                fontSize: 14,
              ),
              filled: true,
              fillColor: tc.background1.withValues(alpha: 0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide(
                  color: tc.divider.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide(
                  color: tc.accent,
                  width: 1.5,
                ),
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitBrainDump(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  provider.isDeconstructing ? null : _submitBrainDump,
              icon: provider.isDeconstructing
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: tc.background1,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(
                provider.isDeconstructing
                    ? 'Architecting...'
                    : 'Deconstruct Goal',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: tc.accent,
                foregroundColor: tc.background1,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.1, end: 0, delay: 400.ms);
  }

  Widget _buildDeconstructingAnimation(ThemeColors tc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: tc.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: tc.accent.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: tc.accent,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .rotate(duration: 2000.ms),
            const SizedBox(height: 20),
            Text(
              'Architecting your path...',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: tc.accent,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn(duration: 1000.ms)
                .then()
                .fadeOut(duration: 1000.ms),
            const SizedBox(height: 8),
            Text(
              'Breaking down your goal into focused micro-tasks',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: tc.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(AppProvider provider, ThemeColors tc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: AppTheme.errorRed.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                provider.errorMessage!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.errorRed,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppTheme.errorRed),
              onPressed: () => provider.clearError(),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).shake(duration: 300.ms);
  }

  Widget _buildGoalCard(
    String title,
    int totalTasks,
    int completedTasks,
    double progress,
    String goalId,
    AppProvider provider,
    ThemeColors tc,
  ) {
    return Dismissible(
      key: Key(goalId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => provider.deleteGoalTasks(goalId),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tc.card, tc.background2],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: progress >= 1.0
                ? tc.accent.withValues(alpha: 0.3)
                : tc.divider.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: tc.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (progress >= 1.0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tc.accent.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusRound),
                    ),
                    child: Text(
                      '✓ Done',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: tc.accent,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '$completedTasks / $totalTasks tasks',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: tc.textMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).round()}%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: tc.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: tc.background1,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0
                      ? tc.accent
                      : tc.accent.withValues(alpha: 0.6),
                ),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
