import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/goals/models/savings_goal.dart';
import '../features/goals/providers/goals_provider.dart';
import '../features/transactions/providers/transactions_provider.dart';
import '../utils/formatters.dart';
import '../widgets/app_logo.dart';
import '../widgets/notification_tile.dart';
import '../theme/app_theme.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionsProvider = context.watch<TransactionsProvider>();
    final goalsProvider = context.watch<GoalsProvider>();
    final notifications = _buildAlerts(
      transactionsProvider: transactionsProvider,
      goalsProvider: goalsProvider,
    );

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
                      'Insights & Alerts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unreadCount > 0
                          ? '$unreadCount areas need attention'
                          : 'Your money flow looks steady',
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
                      child: const AppLogo(
                        size: 44,
                        padding: 7,
                        backgroundColor: Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(14)),
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
                      'NEEDS ATTENTION',
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
                      'INSIGHTS',
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

List<_NotificationData> _buildAlerts({
  required TransactionsProvider transactionsProvider,
  required GoalsProvider goalsProvider,
}) {
  final alerts = <_NotificationData>[];
  final income = transactionsProvider.monthlyIncome;
  final expenses = transactionsProvider.monthlyExpenses;
  final balance = transactionsProvider.currentMonthBalance;
  final safeToSpend = transactionsProvider.safeToSpendToday(
    goalsProvider.dailySavingsRequired,
  );
  final categorySpending = transactionsProvider.categorySpending.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  if (transactionsProvider.transactions.isEmpty) {
    alerts.add(
      const _NotificationData(
        type: NotificationType.info,
        title: 'Start your monthly snapshot',
        message:
            'Add your first income or expense to unlock alerts based on your actual money flow.',
        time: 'Now',
        read: true,
      ),
    );
  }

  if (income > 0 && expenses > income) {
    alerts.add(
      _NotificationData(
        type: NotificationType.alert,
        title: 'Spending is ahead of income',
        message:
            'You are overspent by ${formatCurrency(expenses - income, decimals: 0)} this month. Trim variable expenses before the month closes.',
        time: 'This month',
        read: false,
      ),
    );
  } else if (income > 0) {
    final savingsRate = ((income - expenses) / income) * 100;
    if (savingsRate < 10) {
      alerts.add(
        _NotificationData(
          type: NotificationType.warning,
          title: 'Savings rate is running low',
          message:
              'You are saving ${savingsRate.toStringAsFixed(0)}% of income this month. Try protecting at least 10% before adding more discretionary spend.',
          time: 'This month',
          read: false,
        ),
      );
    } else {
      alerts.add(
        _NotificationData(
          type: NotificationType.success,
          title: 'Savings are on track',
          message:
              'You have kept ${savingsRate.toStringAsFixed(0)}% of income so far this month, with ${formatCurrency(balance, decimals: 0)} still unspent.',
          time: 'This month',
          read: true,
        ),
      );
    }
  }

  if (safeToSpend <= 0 && transactionsProvider.thisMonthTransactions.isNotEmpty) {
    alerts.add(
      const _NotificationData(
        type: NotificationType.alert,
        title: 'Daily buffer is gone',
        message:
            'Today’s safe-to-spend amount is exhausted. Hold non-essential purchases until you add more income or reduce expenses.',
        time: 'Today',
        read: false,
      ),
    );
  } else if (safeToSpend > 0) {
    alerts.add(
      _NotificationData(
        type: NotificationType.info,
        title: 'Safe-to-spend check',
        message:
            'You still have about ${formatCurrency(safeToSpend, decimals: 0)} available for today after reserving money for goals.',
        time: 'Today',
        read: true,
      ),
    );
  }

  if (categorySpending.isNotEmpty && expenses > 0) {
    final topCategory = categorySpending.first;
    final share = (topCategory.value / expenses) * 100;
    if (share >= 35) {
      alerts.add(
        _NotificationData(
          type: NotificationType.warning,
          title: 'One category is dominating spend',
          message:
              '${topCategory.key} accounts for ${share.toStringAsFixed(0)}% of this month’s expenses. Review whether that category needs a cap.',
          time: 'This month',
          read: false,
        ),
      );
    }
  }

  final overdueGoals = goalsProvider.goals.where((goal) {
    final remaining = goal.targetAmount - goal.currentAmount;
    return remaining > 0 &&
        !goal.deadline.isAfter(DateTime.now());
  }).toList();
  if (overdueGoals.isNotEmpty) {
    final goal = overdueGoals.first;
    alerts.add(
      _NotificationData(
        type: NotificationType.alert,
        title: 'A savings goal is overdue',
        message:
            '${goal.name} is past its deadline with ${formatCurrency(goal.targetAmount - goal.currentAmount, decimals: 0)} still left to save.',
        time: 'Goals',
        read: false,
      ),
    );
  } else if (goalsProvider.goals.isNotEmpty) {
    final nearestGoal = goalsProvider.goals
        .where((goal) => goal.targetAmount > goal.currentAmount)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
    if (nearestGoal.isNotEmpty) {
      final goal = nearestGoal.first;
      final remaining = goal.targetAmount - goal.currentAmount;
      final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
      alerts.add(
        _NotificationData(
          type: daysLeft <= 14 ? NotificationType.warning : NotificationType.success,
          title: daysLeft <= 14 ? 'Deadline coming up' : 'Goal progress update',
          message: daysLeft <= 14
              ? '${goal.name} is due in ${daysLeft.clamp(0, 999)} days and still needs ${formatCurrency(remaining, decimals: 0)}.'
              : '${goal.name} is ${_goalProgress(goal).toStringAsFixed(0)}% funded. Keep contributing to stay ahead of schedule.',
          time: 'Goals',
          read: daysLeft > 14,
        ),
      );
    }
  } else {
    alerts.add(
      const _NotificationData(
        type: NotificationType.info,
        title: 'Set a savings goal',
        message:
            'Goals help PennyWise calculate how much to reserve each day and flag when spending starts pushing you off target.',
        time: 'Goals',
        read: true,
      ),
    );
  }

  return alerts;
}

double _goalProgress(SavingsGoal goal) {
  if (goal.targetAmount <= 0) {
    return 0;
  }
  return (goal.currentAmount / goal.targetAmount) * 100;
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
