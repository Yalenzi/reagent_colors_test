import 'package:flutter/material.dart';

enum NotificationType { success, error, warning, info }

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Show overlay notification
  static void showNotification({
    required BuildContext context,
    required String message,
    required NotificationType type,
    Duration duration = const Duration(seconds: 4),
    String? title,
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _NotificationOverlay(
        message: message,
        type: type,
        title: title,
        onTap: onTap,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  // Show success notification
  static void showSuccess({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    showNotification(
      context: context,
      message: message,
      type: NotificationType.success,
      title: title ?? '✅ Success',
      duration: duration,
      onTap: onTap,
    );
  }

  // Show error notification
  static void showError({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 5),
    VoidCallback? onTap,
  }) {
    showNotification(
      context: context,
      message: message,
      type: NotificationType.error,
      title: title ?? '❌ Error',
      duration: duration,
      onTap: onTap,
    );
  }

  // Show warning notification
  static void showWarning({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    showNotification(
      context: context,
      message: message,
      type: NotificationType.warning,
      title: title ?? '⚠️ Warning',
      duration: duration,
      onTap: onTap,
    );
  }

  // Show info notification
  static void showInfo({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    showNotification(
      context: context,
      message: message,
      type: NotificationType.info,
      title: title ?? 'ℹ️ Info',
      duration: duration,
      onTap: onTap,
    );
  }

  // Registration success notification
  static void showRegistrationSuccess({
    required BuildContext context,
    required String username,
  }) {
    showSuccess(
      context: context,
      title: '🎉 Welcome to the Lab!',
      message:
          'Account created successfully for $username. You can now start testing reagents!',
      duration: const Duration(seconds: 5),
    );
  }

  // Login success notification
  static void showLoginSuccess({
    required BuildContext context,
    required String username,
  }) {
    showSuccess(
      context: context,
      title: '🔬 Welcome Back!',
      message: 'Successfully signed in as $username. Ready for testing?',
      duration: const Duration(seconds: 3),
    );
  }

  // Test completion notification
  static void showTestCompleted({
    required BuildContext context,
    required String testName,
  }) {
    showSuccess(
      context: context,
      title: '🧪 Test Completed',
      message: '$testName test has been completed successfully!',
      duration: const Duration(seconds: 4),
    );
  }
}

class _NotificationOverlay extends StatefulWidget {
  final String message;
  final NotificationType type;
  final String? title;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _NotificationOverlay({
    required this.message,
    required this.type,
    this.title,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<_NotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case NotificationType.success:
        return const Color(0xFFF0FDF4);
      case NotificationType.error:
        return const Color(0xFFFEF2F2);
      case NotificationType.warning:
        return const Color(0xFFFFFBEB);
      case NotificationType.info:
        return const Color(0xFFF0F9FF);
    }
  }

  Color _getBorderColor() {
    switch (widget.type) {
      case NotificationType.success:
        return const Color(0xFF10B981);
      case NotificationType.error:
        return const Color(0xFFEF4444);
      case NotificationType.warning:
        return const Color(0xFFF59E0B);
      case NotificationType.info:
        return const Color(0xFF3B82F6);
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case NotificationType.success:
        return const Color(0xFF059669);
      case NotificationType.error:
        return const Color(0xFFDC2626);
      case NotificationType.warning:
        return const Color(0xFFD97706);
      case NotificationType.info:
        return const Color(0xFF1D4ED8);
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getBorderColor().withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getBorderColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIcon(),
                        color: _getBorderColor(),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.title != null)
                            Text(
                              widget.title!,
                              style: TextStyle(
                                color: _getTextColor(),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (widget.title != null) const SizedBox(height: 4),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: _getTextColor().withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _getBorderColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.close,
                          color: _getBorderColor(),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
