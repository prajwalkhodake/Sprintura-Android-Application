import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Animated splash screen with the Sprintura logo and premium loading animation.
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
              // ── Logo with animated glow ──
              _buildAnimatedLogo(),

              const SizedBox(height: 40),

              // ── App name: "SPRINTURA" ──
              Text(
                'SPRINTURA',
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.sageGreen,
                  letterSpacing: 10,
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideY(
                      begin: 0.3, end: 0, delay: 600.ms, duration: 600.ms),

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
              ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),

              const SizedBox(height: 48),

              // ── Circular arc loader ──
              _buildArcLoader(),
            ],
          ),
        ),
      ),
    );
  }

  /// Logo image displayed as a rounded rectangle that blends with the
  /// deep navy background, wrapped in a pulsing sage-green glow.
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowOpacity = 0.12 + (_pulseController.value * 0.3);
        final glowSpread = 2.0 + (_pulseController.value * 10.0);
        final glowBlur = 18.0 + (_pulseController.value * 22.0);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
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
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppTheme.sageGreen.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(27),
          child: Image.asset(
            'assets/app_logo.png',
            fit: BoxFit.cover,
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
