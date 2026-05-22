import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Animated splash screen with the Sprint Architect logo and premium loading animation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;

  @override
  void initState() {
    super.initState();

    // Pulsing glow ring around the logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Rotating arc loader
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _navigateToHome();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Logo with animated glow ring ──
              _buildAnimatedLogo(),

              const SizedBox(height: 40),

              // ── App name: "Sprint" ──
              Text(
                'Sprint',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.softWhite,
                  letterSpacing: 4,
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideY(
                      begin: 0.3, end: 0, delay: 500.ms, duration: 600.ms),

              // ── App name: "ARCHITECT" ──
              Text(
                'ARCHITECT',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.sageGreen,
                  letterSpacing: 8,
                ),
              )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 600.ms)
                  .slideY(
                      begin: 0.3, end: 0, delay: 700.ms, duration: 600.ms),

              const SizedBox(height: 16),

              // ── Tagline ──
              Text(
                'Design your focus. Build your future.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.slateGray,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(delay: 1100.ms, duration: 600.ms),

              const SizedBox(height: 48),

              // ── Circular arc loader ──
              _buildArcLoader(),
            ],
          ),
        ),
      ),
    );
  }

  /// Logo image wrapped in a pulsing glow ring.
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowOpacity = 0.15 + (_pulseController.value * 0.35);
        final glowSpread = 4.0 + (_pulseController.value * 12.0);
        final glowBlur = 20.0 + (_pulseController.value * 20.0);

        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.sageGreen.withValues(alpha: glowOpacity),
                blurRadius: glowBlur,
                spreadRadius: glowSpread,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.midNavy,
              AppTheme.deepNavy,
            ],
          ),
          border: Border.all(
            color: AppTheme.sageGreen.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Image.asset(
              'assets/app_logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 700.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }

  /// Sage-green rotating arc indicator.
  Widget _buildArcLoader() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateController.value * 2 * math.pi,
          child: child,
        );
      },
      child: SizedBox(
        width: 32,
        height: 32,
        child: CustomPaint(
          painter: _ArcPainter(color: AppTheme.sageGreen),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 1400.ms, duration: 400.ms);
  }
}

/// Paints a 270-degree arc with rounded caps.
class _ArcPainter extends CustomPainter {
  final Color color;
  _ArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, -math.pi / 2, 1.5 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
