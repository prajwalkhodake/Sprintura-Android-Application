import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

/// Deep Work Timer Screen — minimalist circular countdown timer.
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  int _selectedMinutes = 25;

  final List<int> _presetDurations = [5, 15, 25, 45, 60];

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Deep Work',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.softWhite,
                        ),
                      ),
                      // Strict mode toggle
                      _buildStrictModeToggle(provider),
                    ],
                  ),
                ),

                // Strict mode warning
                if (provider.strictMode && provider.hasLeftApp)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: AppTheme.errorRed.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_rounded,
                            color: AppTheme.errorRed,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '-10 Focus Coins! Stay focused!',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.errorRed,
                            ),
                          ),
                        ],
                      ),
                    ).animate().shake(duration: 500.ms).fadeIn(),
                  ),

                const Spacer(),

                // Timer circle
                _buildTimerCircle(provider),

                const SizedBox(height: 32),

                // Timer display
                Text(
                  provider.timerDisplay,
                  style: GoogleFonts.inter(
                    fontSize: 56,
                    fontWeight: FontWeight.w200,
                    color: AppTheme.softWhite,
                    letterSpacing: 4,
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 8),

                // Status text
                Text(
                  provider.isTimerRunning
                      ? (provider.isTimerPaused ? 'Paused' : 'Focusing...')
                      : 'Ready to focus',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: provider.isTimerRunning
                        ? AppTheme.sageGreen
                        : AppTheme.slateGray,
                    letterSpacing: 1,
                  ),
                ),

                const Spacer(),

                // Duration presets (only when not running)
                if (!provider.isTimerRunning) _buildDurationPresets(provider),

                const SizedBox(height: 24),

                // Control buttons
                _buildControlButtons(provider),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStrictModeToggle(AppProvider provider) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        provider.setStrictMode(!provider.strictMode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: provider.strictMode
              ? AppTheme.errorRed.withValues(alpha: 0.12)
              : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          border: Border.all(
            color: provider.strictMode
                ? AppTheme.errorRed.withValues(alpha: 0.3)
                : AppTheme.dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              provider.strictMode
                  ? Icons.lock_rounded
                  : Icons.lock_open_rounded,
              size: 16,
              color:
                  provider.strictMode ? AppTheme.errorRed : AppTheme.slateGray,
            ),
            const SizedBox(width: 6),
            Text(
              'Strict',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: provider.strictMode
                    ? AppTheme.errorRed
                    : AppTheme.slateGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCircle(AppProvider provider) {
    final size = MediaQuery.of(context).size.width * 0.6;

    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, child) {
        final breathScale =
            provider.isTimerRunning && !provider.isTimerPaused
                ? 1.0 + (_breathController.value * 0.02)
                : 1.0;

        return Transform.scale(
          scale: breathScale,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: provider.isTimerRunning
                        ? [
                            BoxShadow(
                              color:
                                  AppTheme.sageGreen.withValues(alpha: 0.15),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                ),

                // Background ring
                CustomPaint(
                  size: Size(size, size),
                  painter: _TimerRingPainter(
                    progress: 1.0,
                    color: AppTheme.lightNavy,
                    strokeWidth: 6,
                  ),
                ),

                // Progress ring
                CustomPaint(
                  size: Size(size, size),
                  painter: _TimerRingPainter(
                    progress: provider.timerProgress,
                    color: AppTheme.sageGreen,
                    strokeWidth: 6,
                    hasGlow: true,
                  ),
                ),

                // Inner circle
                Container(
                  width: size * 0.78,
                  height: size * 0.78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.cardBackground,
                        AppTheme.cardBackground.withValues(alpha: 0.8),
                      ],
                    ),
                    border: Border.all(
                      color: AppTheme.dividerColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        provider.isTimerRunning
                            ? Icons.self_improvement_rounded
                            : Icons.play_arrow_rounded,
                        color: AppTheme.sageGreen.withValues(alpha: 0.6),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.isTimerRunning ? 'Stay Present' : 'Begin',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.slateGray,
                          letterSpacing: 1,
                        ),
                      ),
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

  Widget _buildDurationPresets(AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _presetDurations.map((minutes) {
          final isSelected = _selectedMinutes == minutes;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedMinutes = minutes);
                provider.setTimerDuration(minutes);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.sageGreen.withValues(alpha: 0.15)
                      : AppTheme.cardBackground,
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusRound),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.sageGreen.withValues(alpha: 0.4)
                        : AppTheme.dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '${minutes}m',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppTheme.sageGreen
                        : AppTheme.slateGray,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildControlButtons(AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Reset button
          if (provider.isTimerRunning)
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                provider.resetTimer();
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cardBackground,
                  border: Border.all(
                    color: AppTheme.dividerColor,
                  ),
                ),
                child: const Icon(
                  Icons.stop_rounded,
                  color: AppTheme.slateGray,
                  size: 24,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                ),

          if (provider.isTimerRunning) const SizedBox(width: 24),

          // Main button (Start / Pause / Resume)
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              if (!provider.isTimerRunning) {
                provider.startTimer();
              } else if (provider.isTimerPaused) {
                provider.resumeTimer();
              } else {
                provider.pauseTimer();
              }
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: AppTheme.glowShadow,
              ),
              child: Icon(
                provider.isTimerRunning
                    ? (provider.isTimerPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded)
                    : Icons.play_arrow_rounded,
                color: AppTheme.deepNavy,
                size: 32,
              ),
            ),
          ).animate().scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 300.ms,
              ),
        ],
      ),
    );
  }
}

/// Custom painter for the circular timer ring.
class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool hasGlow;

  _TimerRingPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 6,
    this.hasGlow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (hasGlow && progress > 0) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = strokeWidth + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
