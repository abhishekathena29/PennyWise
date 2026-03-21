import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum NotificationType { warning, success, info, alert }

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    this.read = false,
  });

  final String title;
  final String message;
  final NotificationType type;
  final String time;
  final bool read;

  Color _typeColor() {
    switch (type) {
      case NotificationType.warning:
        return AppTheme.warning;
      case NotificationType.success:
        return AppTheme.income;
      case NotificationType.info:
        return const Color(0xFF29B6F6);
      case NotificationType.alert:
        return AppTheme.expense;
    }
  }

  IconData _typeIcon() {
    switch (type) {
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.alert:
        return Icons.trending_down;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _typeColor();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: read ? AppTheme.card : AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_typeIcon(), size: 18, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: read
                              ? AppTheme.mutedForeground
                              : AppTheme.foreground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: read
                        ? AppTheme.mutedForeground
                        : AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
