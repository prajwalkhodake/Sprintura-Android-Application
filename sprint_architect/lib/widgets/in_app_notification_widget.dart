import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/remote_config_model.dart';
import '../theme/app_theme.dart';

/// A collection of premium in-app notification widgets:
/// - [ForceUpdateDialog]: Non-dismissible fullscreen dialog for mandatory updates
/// - [AnnouncementPopup]: Themed modal for promotions, sales, feature announcements
/// - [NotificationBanner]: Dismissible banner for MOTD, tips, low-priority messages

// ═══════════════════════════════════════════════════════════════════════════
// FORCE UPDATE DIALOG — shown when current version < min_version
// ═══════════════════════════════════════════════════════════════════════════

class ForceUpdateDialog extends StatelessWidget {
  final String updateUrl;
  final String latestVersion;
  final ThemeColors tc;

  const ForceUpdateDialog({
    super.key,
    required this.updateUrl,
    required this.latestVersion,
    required this.tc,
  });

  /// Show the force update dialog. Cannot be dismissed.
  static Future<void> show(BuildContext context,
      {required String updateUrl,
      required String latestVersion,
      required ThemeColors tc}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (_) => ForceUpdateDialog(
        updateUrl: updateUrl,
        latestVersion: latestVersion,
        tc: tc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: tc.card,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(
              color: tc.accent.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: tc.accent.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Update icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      tc.accent.withValues(alpha: 0.2),
                      tc.accentDark.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.system_update_rounded,
                  size: 36,
                  color: tc.accent,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Update Required',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: tc.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                'A new version (v$latestVersion) is available with important improvements and bug fixes. Please update to continue using Sprintura.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: tc.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Update button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openStore(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tc.accent,
                    foregroundColor: tc.card,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.download_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Update Now',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore() async {
    final uri = Uri.parse(updateUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANNOUNCEMENT POPUP — for promotions, sales, feature announcements
// ═══════════════════════════════════════════════════════════════════════════

class AnnouncementPopup extends StatelessWidget {
  final AppNotification notification;
  final ThemeColors tc;
  final VoidCallback? onCtaPressed;
  final VoidCallback? onDismissed;

  const AnnouncementPopup({
    super.key,
    required this.notification,
    required this.tc,
    this.onCtaPressed,
    this.onDismissed,
  });

  /// Show the announcement popup.
  static Future<void> show(
    BuildContext context, {
    required AppNotification notification,
    required ThemeColors tc,
    VoidCallback? onCtaPressed,
    VoidCallback? onDismissed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: notification.dismissible,
      barrierColor: Colors.black54,
      builder: (_) => AnnouncementPopup(
        notification: notification,
        tc: tc,
        onCtaPressed: onCtaPressed,
        onDismissed: onDismissed,
      ),
    );
  }

  Color get _priorityAccent {
    switch (notification.priority) {
      case 'critical':
        return AppTheme.errorRed;
      case 'high':
        return AppTheme.warningAmber;
      default:
        return tc.accent;
    }
  }

  IconData get _priorityIcon {
    switch (notification.priority) {
      case 'critical':
        return Icons.warning_amber_rounded;
      case 'high':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _priorityAccent;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: tc.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: accent.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 24,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.12),
              ),
              child: Icon(_priorityIcon, size: 30, color: accent),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              notification.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: tc.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            // Message
            Text(
              notification.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: tc.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Dismiss button
                if (notification.dismissible)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        onDismissed?.call();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: tc.textMuted,
                        side: BorderSide(color: tc.divider),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: Text(
                        'Later',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                if (notification.dismissible && notification.ctaText.isNotEmpty)
                  const SizedBox(width: 12),

                // CTA button
                if (notification.ctaText.isNotEmpty)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onCtaPressed?.call();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: tc.card,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: Text(
                        notification.ctaText,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NOTIFICATION BANNER — dismissible banner for dashboard
// ═══════════════════════════════════════════════════════════════════════════

class NotificationBanner extends StatelessWidget {
  final String title;
  final String message;
  final ThemeColors tc;
  final VoidCallback? onDismiss;
  final IconData icon;
  final Color? accentColor;

  const NotificationBanner({
    super.key,
    required this.title,
    required this.message,
    required this.tc,
    this.onDismiss,
    this.icon = Icons.info_outline_rounded,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? tc.accent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.15),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: tc.textPrimary,
                    ),
                  ),
                if (title.isNotEmpty && message.isNotEmpty)
                  const SizedBox(height: 2),
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: tc.textSecondary,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),

          // Dismiss button
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: tc.textDim,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// UPDATE AVAILABLE BANNER — gentle nudge for optional updates
// ═══════════════════════════════════════════════════════════════════════════

class UpdateAvailableBanner extends StatelessWidget {
  final String latestVersion;
  final String updateUrl;
  final ThemeColors tc;
  final VoidCallback? onDismiss;

  const UpdateAvailableBanner({
    super.key,
    required this.latestVersion,
    required this.updateUrl,
    required this.tc,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tc.accent.withValues(alpha: 0.1),
            tc.accentDark.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: tc.accent.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tc.accent.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.system_update_rounded,
              size: 20,
              color: tc.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Available',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: tc.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'v$latestVersion is ready with new features!',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: tc.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse(updateUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: tc.accent,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                'Update',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: tc.card,
                ),
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close_rounded, size: 18, color: tc.textDim),
            ),
          ],
        ],
      ),
    );
  }
}
