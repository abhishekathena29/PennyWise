import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({
    super.key,
    required this.income,
    required this.expenses,
    required this.savings,
    required this.goalsProgress,
  });

  final double income;
  final double expenses;
  final double savings;
  final int goalsProgress;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatData(
        label: 'Income',
        value: income,
        icon: Icons.trending_up_rounded,
        color: AppTheme.income,
        bgColor: AppTheme.income.withValues(alpha: 0.1),
      ),
      _StatData(
        label: 'Spent',
        value: expenses,
        icon: Icons.trending_down_rounded,
        color: AppTheme.expense,
        bgColor: AppTheme.expense.withValues(alpha: 0.1),
      ),
      _StatData(
        label: 'Saved',
        value: savings,
        icon: Icons.savings_outlined,
        color: AppTheme.primary,
        bgColor: AppTheme.primary.withValues(alpha: 0.1),
      ),
      _StatData(
        label: 'Goals',
        value: goalsProgress.toDouble(),
        icon: Icons.flag_rounded,
        color: const Color(0xFF7E57C2),
        bgColor: const Color(0xFF7E57C2).withValues(alpha: 0.1),
        isPercent: true,
      ),
    ];

    return Row(
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _StatCard(stat: stats[i])),
        ],
      ],
    );
  }
}

class _StatData {
  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.isPercent = false,
  });

  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool isPercent;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _StatData stat;

  @override
  Widget build(BuildContext context) {
    final valueText = stat.isPercent
        ? '${stat.value.toStringAsFixed(0)}%'
        : formatCompactCurrency(stat.value);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: stat.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, size: 18, color: stat.color),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valueText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: stat.color,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            stat.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.mutedForeground,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
