import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Animated splash screen with the Sprint Architect branding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2800));
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
              // App icon with glow
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: AppTheme.glowShadow,
                ),
                child: const Icon(
                  Icons.architecture_rounded,
                  size: 48,
                  color: AppTheme.deepNavy,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              // App name
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
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 600.ms),

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
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 600.ms),

              const SizedBox(height: 16),

              // Tagline
              Text(
                'Design your focus. Build your future.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.slateGray,
                  letterSpacing: 1,
                ),
              )
                  .animate()
                  .fadeIn(delay: 1000.ms, duration: 600.ms),

              const SizedBox(height: 48),

              // Loading indicator
              SizedBox(
                width: 160,
                child: LinearProgressIndicator(
                  backgroundColor: AppTheme.lightNavy,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.sageGreen,
                  ),
                  minHeight: 2,
                ),
              )
                  .animate()
                  .fadeIn(delay: 1200.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
