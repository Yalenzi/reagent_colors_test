import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationDemoWidget extends StatelessWidget {
  const NotificationDemoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🧪 Notification Demo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Test different notification types:',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDemoButton(
                context: context,
                label: 'Success',
                color: const Color(0xFF10B981),
                onPressed: () => NotificationService.showSuccess(
                  context: context,
                  message: 'Test completed successfully!',
                ),
              ),
              _buildDemoButton(
                context: context,
                label: 'Error',
                color: const Color(0xFFEF4444),
                onPressed: () => NotificationService.showError(
                  context: context,
                  message: 'Something went wrong!',
                ),
              ),
              _buildDemoButton(
                context: context,
                label: 'Warning',
                color: const Color(0xFFF59E0B),
                onPressed: () => NotificationService.showWarning(
                  context: context,
                  message: 'Please check your input!',
                ),
              ),
              _buildDemoButton(
                context: context,
                label: 'Info',
                color: const Color(0xFF3B82F6),
                onPressed: () => NotificationService.showInfo(
                  context: context,
                  message: 'Here\'s some useful information!',
                ),
              ),
              _buildDemoButton(
                context: context,
                label: 'Registration',
                color: const Color(0xFF8B5CF6),
                onPressed: () => NotificationService.showRegistrationSuccess(
                  context: context,
                  username: 'TestUser',
                ),
              ),
              _buildDemoButton(
                context: context,
                label: 'Login',
                color: const Color(0xFF06B6D4),
                onPressed: () => NotificationService.showLoginSuccess(
                  context: context,
                  username: 'TestUser',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton({
    required BuildContext context,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
