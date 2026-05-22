import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final tc = AppTheme.getThemeColors(provider.activeTheme);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [tc.background1, tc.background2],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dashboard', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: tc.textPrimary)).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),
                  _buildStreakCard(provider, tc),
                  const SizedBox(height: 16),
                  _buildStatsGrid(provider, tc),
                  const SizedBox(height: 24),
                  
                  // Success/Error banners
                  if (provider.successMessage != null) _buildBanner(provider.successMessage!, tc.accent, tc, () => provider.clearSuccess()),
                  if (provider.errorMessage != null) _buildBanner(provider.errorMessage!, AppTheme.errorRed, tc, () => provider.clearError()),
                  if (provider.successMessage != null || provider.errorMessage != null) const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.stars_rounded, color: tc.textPrimary, size: 24),
                      const SizedBox(width: 8),
                      Text('Daily Rewards', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: tc.textPrimary)),
                    ],
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                  const SizedBox(height: 12),
                  _buildDailyRewards(context, provider, tc),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Icon(Icons.settings_rounded, color: tc.textPrimary, size: 24),
                      const SizedBox(width: 8),
                      Text('Settings', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: tc.textPrimary)),
                    ],
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                  const SizedBox(height: 12),
                  _buildSettingsCard(context, provider, tc),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner(String msg, Color color, ThemeColors tc, VoidCallback onDismiss) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(children: [
        Expanded(child: Text(msg, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: color))),
        GestureDetector(onTap: onDismiss, child: Icon(Icons.close, size: 16, color: color)),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStreakCard(AppProvider provider, ThemeColors tc) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [tc.card, tc.background2]),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.local_fire_department_rounded, color: AppTheme.warningAmber, size: 32),
          const SizedBox(width: 12),
          Text('${provider.stats.currentStreak}', style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w700, color: AppTheme.warningAmber)),
        ]),
        Text('Day Streak', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: tc.textPrimary, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text('Longest: ${provider.stats.longestStreak} days', style: GoogleFonts.inter(fontSize: 12, color: tc.textMuted)),
        if (provider.stats.streakShields > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF4FC3F7).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppTheme.radiusRound)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_rounded, size: 12, color: Color(0xFF4FC3F7)),
                const SizedBox(width: 4),
                Text('${provider.stats.streakShields} Shield${provider.stats.streakShields > 1 ? 's' : ''} Active', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF4FC3F7))),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(7, (i) {
          final isActive = i < provider.stats.currentStreak.clamp(0, 7);
          return Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: AnimatedContainer(
            duration: const Duration(milliseconds: 300), width: 32, height: 32,
            decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? AppTheme.warningAmber.withValues(alpha: 0.2) : tc.divider, border: Border.all(color: isActive ? AppTheme.warningAmber : tc.divider, width: isActive ? 2 : 1)),
            child: isActive ? const Icon(Icons.check, size: 14, color: AppTheme.warningAmber) : null,
          ));
        })),
      ]),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, delay: 100.ms);
  }

  Widget _buildStatsGrid(AppProvider provider, ThemeColors tc) {
    return Row(children: [
      Expanded(child: _statCard(Icons.schedule_rounded, provider.stats.focusHours, 'Total Focus', tc.accent, tc)),
      const SizedBox(width: 12),
      Expanded(child: _statCard(Icons.flash_on_rounded, '${provider.stats.totalSessions}', 'Sessions', const Color(0xFFB388FF), tc)),
      const SizedBox(width: 12),
      Expanded(child: _statCard(Icons.monetization_on_rounded, '${provider.stats.focusCoins}', 'Coins', const Color(0xFFFFD700), tc)),
    ]).animate().fadeIn(delay: 250.ms, duration: 400.ms);
  }

  Widget _statCard(IconData icon, String value, String label, Color color, ThemeColors tc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: tc.card, borderRadius: BorderRadius.circular(AppTheme.radiusLg), border: Border.all(color: color.withValues(alpha: 0.15))),
      child: Column(children: [
        Icon(icon, color: color, size: 24), const SizedBox(height: 8),
        Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: tc.textPrimary)), const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: tc.textMuted)),
      ]),
    );
  }

  Widget _buildDailyRewards(BuildContext context, AppProvider provider, ThemeColors tc) {
    final now = DateTime.now();
    bool isNewDay = provider.stats.lastAdWatchDate == null ||
        now.difference(provider.stats.lastAdWatchDate!).inDays >= 1 ||
        now.day != provider.stats.lastAdWatchDate!.day;

    final coinsWatched = isNewDay ? 0 : provider.stats.adCoinsWatchedToday;
    final aiWatched = isNewDay ? 0 : provider.stats.adAiWatchedToday;

    return Column(children: [
      _rewardItem(
        icon: Icons.play_circle_filled_rounded,
        title: 'Watch & Earn Coins',
        subtitle: 'Earn 25 coins ($coinsWatched/5 today)',
        buttonText: 'WATCH',
        isMaxed: coinsWatched >= 5,
        buttonColor: const Color(0xFFFFD700),
        tc: tc,
        onTap: () {
          if (coinsWatched < 5) provider.watchAdForCoins();
        },
      ),
      const SizedBox(height: 10),
      _rewardItem(
        icon: Icons.auto_awesome_rounded,
        title: 'AI Uses Refill',
        subtitle: 'Earn 3 AI Uses ($aiWatched/3 today)',
        buttonText: 'WATCH',
        isMaxed: aiWatched >= 3,
        buttonColor: const Color(0xFFB388FF),
        tc: tc,
        onTap: () {
          if (aiWatched < 3) provider.watchAdForAIUses();
        },
      ),
    ]).animate().fadeIn(delay: 350.ms, duration: 400.ms);
  }

  Widget _rewardItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required bool isMaxed,
    required Color buttonColor,
    required ThemeColors tc,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: tc.card, borderRadius: BorderRadius.circular(AppTheme.radiusLg), border: Border.all(color: tc.divider.withValues(alpha: 0.5))),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: isMaxed ? tc.divider : buttonColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
          child: Icon(icon, color: isMaxed ? tc.textMuted : buttonColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: tc.textPrimary)), const SizedBox(height: 2),
          Text(isMaxed ? 'Daily limit reached' : subtitle, style: GoogleFonts.inter(fontSize: 12, color: tc.textMuted)),
        ])),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: isMaxed ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isMaxed ? tc.divider : buttonColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              border: Border.all(color: isMaxed ? tc.divider : buttonColor.withValues(alpha: 0.3)),
            ),
            child: Text(isMaxed ? 'DONE' : buttonText, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isMaxed ? tc.textMuted : buttonColor)),
          ),
        ),
      ]),
    );
  }

  Widget _buildSettingsCard(BuildContext context, AppProvider provider, ThemeColors tc) {
    return Container(
      decoration: BoxDecoration(color: tc.card, borderRadius: BorderRadius.circular(AppTheme.radiusLg), border: Border.all(color: tc.divider.withValues(alpha: 0.5))),
      child: Column(children: [
        ListTile(leading: Icon(Icons.lock_rounded, color: tc.textMuted, size: 22), title: Text('Strict Mode', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: tc.textPrimary)), subtitle: Text('Deduct coins when leaving app', style: GoogleFonts.inter(fontSize: 12, color: tc.textDim)), trailing: Switch(value: provider.strictMode, onChanged: (v) => provider.setStrictMode(v))),
        Divider(height: 1, color: tc.divider.withValues(alpha: 0.5)),
        ListTile(leading: Icon(Icons.info_outline_rounded, color: tc.textMuted, size: 22), title: Text('About Sprintura', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: tc.textPrimary)), subtitle: Text('Version 1.1.0', style: GoogleFonts.inter(fontSize: 12, color: tc.textDim)), onTap: () => _showAbout(context, tc)),
      ]),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }

  void _showAbout(BuildContext context, ThemeColors tc) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: tc.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
      title: Text('Sprintura', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: tc.textPrimary)),
      content: Text('Design your focus. Build your future.\n\nNow with Coin Shop, Premium Themes, and Ambient Sounds!\n\nVersion 1.1.0', style: GoogleFonts.inter(fontSize: 14, color: tc.textSecondary, height: 1.6)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: GoogleFonts.inter(color: tc.accent, fontWeight: FontWeight.w600)))],
    ));
  }
}
