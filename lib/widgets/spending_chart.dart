import 'package:flutter/material.dart';

import '../models/category.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class SpendingChart extends StatelessWidget {
  const SpendingChart({
    super.key,
    required this.categorySpending,
    required this.categories,
  });

  final Map<String, double> categorySpending;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final data =
        categorySpending.entries
            .map((entry) {
              final category = categories.firstWhere(
                (c) => c.id == entry.key,
                orElse: () => Category(
                  id: entry.key,
                  name: 'Other',
                  icon: '📦',
                  color: AppTheme.mutedForeground,
                ),
              );
              return _SpendingItem(
                name: category.name,
                value: entry.value,
                color: category.color,
                icon: category.icon,
              );
            })
            .where((item) => item.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
        ),
        child: const Center(
          child: Text(
            'No spending data yet.\nAdd expenses to see breakdown.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12),
          ),
        ),
      );
    }

    final total = data.fold(0.0, (sum, item) => sum + item.value);
    final maxValue = data.first.value == 0 ? 1 : data.first.value;

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
            children: const [
              Text(
                'Spending Breakdown',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'This month',
                style: TextStyle(fontSize: 12, color: AppTheme.mutedForeground),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              for (final item in data.take(5))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SpendingRow(
                    item: item,
                    total: total,
                    maxValue: maxValue.toDouble(),
                  ),
                ),
            ],
          ),
          if (data.length > 5)
            TextButton(
              onPressed: () {},
              child: const Text('View all categories'),
            ),
        ],
      ),
    );
  }
}

class _SpendingItem {
  _SpendingItem({
    required this.name,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String name;
  final double value;
  final Color color;
  final String icon;
}

class _SpendingRow extends StatelessWidget {
  const _SpendingRow({
    required this.item,
    required this.total,
    required this.maxValue,
  });

  final _SpendingItem item;
  final double total;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0 : (item.value / total) * 100;
    final double barWidth = maxValue == 0 ? 0 : (item.value / maxValue);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatCurrency(item.value, decimals: 0),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: barWidth.clamp(0, 1),
            minHeight: 6,
            backgroundColor: AppTheme.muted,
            color: item.color,
          ),
        ),
      ],
    );
  }
}
