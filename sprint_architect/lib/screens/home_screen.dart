import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/in_app_notification_widget.dart';
import 'focus_hub_screen.dart';
import 'tasks_screen.dart';
import 'timer_screen.dart';
import 'profile_screen.dart';
import 'shop_screen.dart';

/// Main home screen with bottom navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _hasCheckedRemoteConfig = false;

  final List<Widget> _screens = const [
    FocusHubScreen(),
    TasksScreen(),
    TimerScreen(),
    ShopScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Check remote config after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRemoteNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Detect app backgrounding for strict mode
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App went to background
      context.read<AppProvider>().onAppBackgrounded();
    }
  }

  /// Check for force-update dialogs and popup announcements from remote config.
  Future<void> _checkRemoteNotifications() async {
    if (_hasCheckedRemoteConfig || !mounted) return;
    _hasCheckedRemoteConfig = true;

    final provider = context.read<AppProvider>();
    if (!provider.isRemoteConfigLoaded) return;

    final tc = AppTheme.getThemeColors(provider.activeTheme);

    // 1. Force update check (highest priority, non-dismissible)
    if (provider.needsForceUpdate) {
      if (mounted) {
        await ForceUpdateDialog.show(
          context,
          updateUrl: provider.remoteConfig.updateUrl,
          latestVersion: provider.remoteConfig.latestVersion,
          tc: tc,
        );
      }
      return; // Don't show other notifications if force update is needed
    }

    // 2. Show popup-type announcements (one at a time)
    final popups = provider.activePopups;
    for (final popup in popups) {
      if (!mounted) return;
      await AnnouncementPopup.show(
        context,
        notification: popup,
        tc: tc,
        onCtaPressed: () => _handleCtaAction(popup, provider),
        onDismissed: () => provider.dismissNotification(popup.id),
      );
      // Dismiss after showing regardless (so it only shows once)
      await provider.dismissNotification(popup.id);
    }
  }

  /// Handle the CTA action from an announcement popup.
  void _handleCtaAction(dynamic notification, AppProvider provider) {
    switch (notification.ctaAction) {
      case 'shop':
        setState(() => _currentIndex = 3); // Switch to Shop tab
        break;
      case 'url':
        // URL launching is handled by the widget itself
        break;
      case 'update':
        // Update is handled by the widget
        break;
      case 'dismiss':
      default:
        break;
    }
    provider.dismissNotification(notification.id);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final tc = AppTheme.getThemeColors(provider.activeTheme);
        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _screens[_currentIndex],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: tc.background2,
              border: Border(
                top: BorderSide(
                  color: tc.divider.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, 'Focus Hub', tc),
                    _buildNavItem(1, Icons.checklist_rounded, 'Tasks', tc),
                    _buildNavItem(2, Icons.timer_rounded, 'Timer', tc),
                    _buildNavItem(3, Icons.storefront_rounded, 'Shop', tc),
                    _buildNavItem(4, Icons.person_rounded, 'Profile', tc),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, ThemeColors tc) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? tc.accent.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? tc.accent : tc.textDim,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? tc.accent : tc.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
