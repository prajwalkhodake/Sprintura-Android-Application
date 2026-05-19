import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                  const SizedBox(height: 8),
                  Text('🛍️ Coin Shop', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: tc.textPrimary)).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                  const SizedBox(height: 4),
                  Text('Spend your hard-earned Focus Coins', style: GoogleFonts.inter(fontSize: 13, color: tc.textMuted)),
                  const SizedBox(height: 12),
                  _buildCoinShop(context, provider, tc),
                  const SizedBox(height: 24),
                  Text('🎨 Theme Gallery', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: tc.textPrimary)).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                  const SizedBox(height: 12),
                  _buildThemeGallery(context, provider, tc),
                  const SizedBox(height: 24),
                  Text('🎵 Ambient Sounds', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: tc.textPrimary)).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                  const SizedBox(height: 12),
                  _buildSoundShop(context, provider, tc),
                  const SizedBox(height: 24),
                  Text('⚙️ Settings', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: tc.textPrimary)).animate().fadeIn(delay: 700.ms, duration: 400.ms),
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
            child: Text('🛡️ ${provider.stats.streakShields} Shield${provider.stats.streakShields > 1 ? 's' : ''} Active', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF4FC3F7))),
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

  Widget _buildCoinShop(BuildContext context, AppProvider provider, ThemeColors tc) {
    return Column(children: [
      _shopItem(icon: Icons.play_circle_filled_rounded, title: 'Watch to Earn', subtitle: 'Watch a short ad to earn 25 coins', buttonText: 'FREE', cost: 0, buttonColor: const Color(0xFFFFD700), tc: tc, onTap: () { HapticFeedback.mediumImpact(); provider.watchAdForCoins(); }),
      const SizedBox(height: 10),
      _shopItem(icon: Icons.auto_awesome_rounded, title: 'AI Refill (Ad)', subtitle: 'Watch a short ad for 3 AI Uses', buttonText: 'FREE', cost: 0, buttonColor: const Color(0xFFB388FF), tc: tc, onTap: () { HapticFeedback.mediumImpact(); provider.watchAdForAIUses(); }),
      const SizedBox(height: 10),
      _shopItem(icon: Icons.psychology_rounded, title: 'Ad-Free AI Refill', subtitle: 'Buy 5 AI Uses with your coins', buttonText: '100 🪙', cost: 100, buttonColor: const Color(0xFFB388FF), tc: tc, onTap: () { HapticFeedback.mediumImpact(); _confirmPurchase(context, 'Buy 5 AI Uses for 100 coins?', tc, () => provider.purchaseAIRefill()); }),
      const SizedBox(height: 10),
      _shopItem(icon: Icons.shield_rounded, title: 'Streak Shield', subtitle: 'Protect your streak if you miss a day', buttonText: '300 🪙', cost: 300, buttonColor: const Color(0xFF4FC3F7), tc: tc, onTap: () { HapticFeedback.mediumImpact(); _confirmPurchase(context, 'Buy a Streak Shield for 300 coins?', tc, () => provider.purchaseStreakShield()); }),
    ]).animate().fadeIn(delay: 450.ms, duration: 400.ms);
  }

  Widget _buildThemeGallery(BuildContext context, AppProvider provider, ThemeColors tc) {
    final themes = AppTheme.themePresets;
    return Column(children: themes.entries.map((e) {
      final id = e.key;
      final t = e.value;
      final isUnlocked = provider.stats.isThemeUnlocked(id);
      final isActive = provider.activeTheme == id;
      return Container(
        margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: tc.card, borderRadius: BorderRadius.circular(AppTheme.radiusLg), border: Border.all(color: isActive ? t.accent.withValues(alpha: 0.5) : tc.divider.withValues(alpha: 0.4), width: isActive ? 2 : 1)),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppTheme.radiusMd), color: t.background1, border: Border.all(color: t.accent.withValues(alpha: 0.4))),
            child: Center(child: Text(t.icon, style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: tc.textPrimary)),
            const SizedBox(height: 2),
            Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: t.accent)), const SizedBox(width: 4), Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: t.background1)), const SizedBox(width: 4), Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: t.card))]),
          ])),
          if (isActive) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: t.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppTheme.radiusRound)), child: Text('Active', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: t.accent)))
          else if (isUnlocked) GestureDetector(onTap: () => provider.switchTheme(id), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: tc.divider, borderRadius: BorderRadius.circular(AppTheme.radiusRound)), child: Text('Apply', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: tc.textSecondary))))
          else GestureDetector(onTap: () { HapticFeedback.mediumImpact(); _confirmPurchase(context, 'Unlock "${t.name}" theme for 1000 coins?', tc, () => provider.purchaseTheme(id)); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFD700).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppTheme.radiusRound), border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3))), child: Text('1000 🪙', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFFFD700))))),
        ]),
      );
    }).toList()).animate().fadeIn(delay: 550.ms, duration: 400.ms);
  }

  Widget _buildSoundShop(BuildContext context, AppProvider provider, ThemeColors tc) {
    final sounds = {'rain': ['🌧️', 'Gentle Rain'], 'forest_stream': ['🌊', 'Forest Stream'], 'cosmic': ['✨', 'Cosmic White Noise']};
    return Column(children: sounds.entries.map((e) {
      final id = e.key;
      final icon = e.value[0];
      final name = e.value[1];
      final isUnlocked = provider.stats.isSoundUnlocked(id);
      final isActive = provider.activeSound == id;
      return Container(
        margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: tc.card, borderRadius: BorderRadius.circular(AppTheme.radiusLg), border: Border.all(color: isActive ? tc.accent.withValues(alpha: 0.4) : tc.divider.withValues(alpha: 0.4))),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: tc.textPrimary)),
            Text(isUnlocked ? 'Unlocked' : 'Play during focus sessions', style: GoogleFonts.inter(fontSize: 12, color: tc.textMuted)),
          ])),
          if (isActive) GestureDetector(onTap: () => provider.setActiveSound('none'), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: tc.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppTheme.radiusRound)), child: Text('Playing', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: tc.accent))))
          else if (isUnlocked) GestureDetector(onTap: () => provider.setActiveSound(id), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: tc.divider, borderRadius: BorderRadius.circular(AppTheme.radiusRound)), child: Text('Play', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: tc.textSecondary))))
          else GestureDetector(onTap: () { HapticFeedback.mediumImpact(); _confirmPurchase(context, 'Unlock "$name" for 500 coins?', tc, () => provider.purchaseSound(id)); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFD700).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppTheme.radiusRound), border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3))), child: Text('500 🪙', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFFFD700))))),
        ]),
      );
    }).toList()).animate().fadeIn(delay: 650.ms, duration: 400.ms);
  }

  Widget _shopItem({required IconData icon, required String title, required String subtitle, required String buttonText, required int cost, required Color buttonColor, required ThemeColors tc, required VoidCallback onTap}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: tc.card, borderRadius: BorderRadius.circular(AppTheme.radiusLg), border: Border.all(color: tc.divider.withValues(alpha: 0.5))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: buttonColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppTheme.radiusMd)), child: Icon(icon, color: buttonColor, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: tc.textPrimary)), const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: tc.textMuted)),
        ])),
        const SizedBox(width: 8),
        GestureDetector(onTap: onTap, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: buttonColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppTheme.radiusRound), border: Border.all(color: buttonColor.withValues(alpha: 0.3))),
          child: Text(buttonText, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: buttonColor)),
        )),
      ]),
    );
  }

  Widget _buildSettingsCard(BuildContext context, AppProvider provider, ThemeColors tc) {
    return Container(
      decoration: BoxDecoration(color: tc.card, borderRadius: BorderRadius.circular(AppTheme.radiusLg), border: Border.all(color: tc.divider.withValues(alpha: 0.5))),
      child: Column(children: [
        ListTile(leading: Icon(Icons.lock_rounded, color: tc.textMuted, size: 22), title: Text('Strict Mode', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: tc.textPrimary)), subtitle: Text('Deduct coins when leaving app', style: GoogleFonts.inter(fontSize: 12, color: tc.textDim)), trailing: Switch(value: provider.strictMode, onChanged: (v) => provider.setStrictMode(v))),
        Divider(height: 1, color: tc.divider.withValues(alpha: 0.5)),
        ListTile(leading: Icon(Icons.info_outline_rounded, color: tc.textMuted, size: 22), title: Text('About Sprint Architect', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: tc.textPrimary)), subtitle: Text('Version 1.1.0', style: GoogleFonts.inter(fontSize: 12, color: tc.textDim)), onTap: () => _showAbout(context, tc)),
      ]),
    ).animate().fadeIn(delay: 800.ms, duration: 400.ms);
  }

  void _confirmPurchase(BuildContext context, String message, ThemeColors tc, Future<bool> Function() action) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: tc.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
      title: Text('Confirm Purchase', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: tc.textPrimary)),
      content: Text(message, style: GoogleFonts.inter(fontSize: 14, color: tc.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(color: tc.textMuted))),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); action(); }, child: const Text('Buy')),
      ],
    ));
  }

  void _showAbout(BuildContext context, ThemeColors tc) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: tc.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
      title: Text('Sprint Architect', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: tc.textPrimary)),
      content: Text('Design your focus. Build your future.\n\nNow with Coin Shop, Premium Themes, and Ambient Sounds!\n\nVersion 1.1.0', style: GoogleFonts.inter(fontSize: 14, color: tc.textSecondary, height: 1.6)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: GoogleFonts.inter(color: tc.accent, fontWeight: FontWeight.w600)))],
    ));
  }
}
