import 'package:flutter/material.dart';

import '../widgets/notification_tile.dart';
import '../theme/app_theme.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _NotificationData(
        type: NotificationType.warning,
        title: 'Budget Alert',
        message: "You've spent 80% of your Food & Dining budget this month.",
        time: '2h ago',
        read: false,
      ),
      _NotificationData(
        type: NotificationType.success,
        title: 'Goal Milestone',
        message: 'Emergency Fund is now 47% complete! Keep it up! 🎉',
        time: '5h ago',
        read: false,
      ),
      _NotificationData(
        type: NotificationType.info,
        title: 'Weekly Summary',
        message: 'You spent ₹289.49 this week, 12% less than last week.',
        time: '1d ago',
        read: true,
      ),
      _NotificationData(
        type: NotificationType.alert,
        title: 'Unusual Spending',
        message: 'Shopping expenses are 2x higher than your monthly average.',
        time: '2d ago',
        read: true,
      ),
      _NotificationData(
        type: NotificationType.success,
        title: 'Streak! 🔥',
        message: "You've logged expenses for 7 days in a row!",
        time: '3d ago',
        read: true,
      ),
      _NotificationData(
        type: NotificationType.info,
        title: 'Tip of the Day',
        message: 'Try the 50/30/20 rule: 50% needs, 30% wants, 20% savings.',
        time: '4d ago',
        read: true,
      ),
    ];

    final unreadCount = notifications.where((n) => !n.read).length;
    final unread = notifications.where((n) => !n.read).toList();
    final read = notifications.where((n) => n.read).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Dark gradient header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: AppTheme.darkGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unreadCount > 0
                          ? '$unreadCount unread'
                          : 'All caught up!',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Notification list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (unread.isNotEmpty) ...[
                    const Text(
                      'NEW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.mutedForeground,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final n in unread) ...[
                      NotificationTile(
                        title: n.title,
                        message: n.message,
                        type: n.type,
                        time: n.time,
                        read: n.read,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                  if (read.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'EARLIER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.mutedForeground,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final n in read) ...[
                      NotificationTile(
                        title: n.title,
                        message: n.message,
                        type: n.type,
                        time: n.time,
                        read: n.read,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationData {
  const _NotificationData({
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.read,
  });

  final NotificationType type;
  final String title;
  final String message;
  final String time;
  final bool read;
}
