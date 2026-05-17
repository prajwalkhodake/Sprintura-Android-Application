import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

/// Profile screen — stats dashboard, streak, coin shop, and settings.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Dashboard',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.softWhite,
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  // Streak card
                  _buildStreakCard(provider),

                  const SizedBox(height: 16),

                  // Stats grid
                  _buildStatsGrid(provider),

                  const SizedBox(height: 24),

                  // Coin Shop section
                  Text(
                    'Coin Shop',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.softWhite,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms),

                  const SizedBox(height: 12),

                  _buildCoinShop(context, provider),

                  const SizedBox(height: 24),

                  // Settings section
                  Text(
                    'Settings',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.softWhite,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 400.ms),

                  const SizedBox(height: 12),

                  _buildSettingsCard(context, provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreakCard(AppProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E),
            AppTheme.cardBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: AppTheme.warningAmber.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warningAmber.withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: AppTheme.warningAmber,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                '${provider.stats.currentStreak}',
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.warningAmber,
                ),
              ),
            ],
          ),
          Text(
            'Day Streak',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.softWhite,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Longest: ${provider.stats.longestStreak} days',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.slateGray,
            ),
          ),
          const SizedBox(height: 16),

          // Streak visualization (last 7 days)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (index) {
              final isActive = index < provider.stats.currentStreak.clamp(0, 7);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? AppTheme.warningAmber.withValues(alpha: 0.2)
                            : AppTheme.lightNavy,
                        border: Border.all(
                          color: isActive
                              ? AppTheme.warningAmber
                              : AppTheme.dividerColor,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: isActive
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: AppTheme.warningAmber,
                            )
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDayLabel(index),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: isActive
                            ? AppTheme.warningAmber
                            : AppTheme.dimGray,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 500.ms)
        .slideY(begin: 0.1, end: 0, delay: 100.ms);
  }

  String _getDayLabel(int index) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1; // 0=Mon
    final dayIndex = (today - 6 + index) % 7;
    return days[dayIndex.clamp(0, 6)];
  }

  Widget _buildStatsGrid(AppProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.schedule_rounded,
            provider.stats.focusHours,
            'Total Focus',
            AppTheme.sageGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.flash_on_rounded,
            '${provider.stats.totalSessions}',
            'Sessions',
            const Color(0xFFB388FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.monetization_on_rounded,
            '${provider.stats.focusCoins}',
            'Coins',
            const Color(0xFFFFD700),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 250.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, delay: 250.ms);
  }

  Widget _buildStatCard(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.softWhite,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.slateGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinShop(BuildContext context, AppProvider provider) {
    return Column(
      children: [
        // Watch to earn coins
        _buildShopItem(
          icon: Icons.play_circle_filled_rounded,
          title: 'Watch to Earn',
          subtitle: 'Watch a short ad to earn 25 Focus Coins',
          buttonText: '+25 Coins',
          buttonColor: const Color(0xFFFFD700),
          onTap: () {
            HapticFeedback.mediumImpact();
            provider.watchAdForCoins();
          },
        ),
        const SizedBox(height: 12),

        // Watch to earn AI uses
        _buildShopItem(
          icon: Icons.auto_awesome_rounded,
          title: 'AI Refill',
          subtitle: 'Watch a short ad to earn 3 AI Uses',
          buttonText: '+3 AI Uses',
          buttonColor: const Color(0xFFB388FF),
          onTap: () {
            HapticFeedback.mediumImpact();
            provider.watchAdForAIUses();
          },
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, delay: 500.ms);
  }

  Widget _buildShopItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: buttonColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: buttonColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.softWhite,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.slateGray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: buttonColor.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusRound),
                border: Border.all(
                  color: buttonColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: buttonColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, AppProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            Icons.lock_rounded,
            'Strict Mode',
            'Deduct coins when leaving app during focus',
            trailing: Switch(
              value: provider.strictMode,
              onChanged: (v) => provider.setStrictMode(v),
            ),
          ),
          Divider(
            height: 1,
            color: AppTheme.dividerColor.withValues(alpha: 0.5),
          ),
          _buildSettingItem(
            Icons.info_outline_rounded,
            'About Sprint Architect',
            'Version 1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, delay: 700.ms);
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.slateGray, size: 22),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.softWhite,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppTheme.dimGray,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(
          'Sprint Architect',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppTheme.softWhite,
          ),
        ),
        content: Text(
          'Design your focus. Build your future.\n\n'
          'Sprint Architect helps you break down big goals into '
          'micro-tasks and complete them with focused deep work sessions.\n\n'
          'Version 1.0.0',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.lightGray,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.inter(
                color: AppTheme.sageGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
