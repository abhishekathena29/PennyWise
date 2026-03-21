import 'package:flutter/material.dart';

import '../models/savings_goal.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class GoalProgress extends StatelessWidget {
  const GoalProgress({
    super.key,
    required this.goals,
    required this.onAddGoal,
    required this.onContribute,
  });

  final List<SavingsGoal> goals;
  final VoidCallback onAddGoal;
  final ValueChanged<SavingsGoal> onContribute;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.flag,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Savings Goals',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              TextButton(onPressed: onAddGoal, child: const Text('Add')),
            ],
          ),
          const SizedBox(height: 12),
          if (goals.isEmpty)
            Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.muted,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.flag_outlined,
                    color: AppTheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'No goals yet',
                  style: TextStyle(color: AppTheme.mutedForeground),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: onAddGoal,
                  child: const Text('Create your first goal'),
                ),
              ],
            )
          else
            Column(
              children: [
                for (final goal in goals.take(3))
                  _GoalTile(goal: goal, onContribute: onContribute),
                if (goals.length > 3)
                  TextButton(
                    onPressed: () {},
                    child: Text('View all ${goals.length} goals'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.goal, required this.onContribute});

  final SavingsGoal goal;
  final ValueChanged<SavingsGoal> onContribute;

  @override
  Widget build(BuildContext context) {
    final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
    return InkWell(
      onTap: () => onContribute(goal),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            MiniCircularProgress(
              value: goal.currentAmount,
              max: goal.targetAmount,
              color: goal.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatCurrency(goal.currentAmount, decimals: 0)} / ${formatCurrency(goal.targetAmount, decimals: 0)} • ${daysLeft < 0 ? 0 : daysLeft}d left',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppTheme.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

class MiniCircularProgress extends StatelessWidget {
  const MiniCircularProgress({
    super.key,
    required this.value,
    required this.max,
    required this.color,
  });

  final double value;
  final double max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double progress = max == 0 ? 0 : (value / max).clamp(0, 1);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: AppTheme.muted,
            color: color,
          ),
        ),
        Text(
          '${(progress * 100).round()}%',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
