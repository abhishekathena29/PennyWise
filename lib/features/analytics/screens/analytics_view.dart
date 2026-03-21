import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../transactions/models/category.dart';
import '../../transactions/models/transaction.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({
    super.key,
    required this.transactions,
    required this.categories,
    required this.categorySpending,
    required this.monthlyIncome,
    required this.monthlyExpenses,
  });

  final List<Transaction> transactions;
  final List<Category> categories;
  final Map<String, double> categorySpending;
  final double monthlyIncome;
  final double monthlyExpenses;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final last7Days = List.generate(
      7,
      (index) => DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index)),
    );

    final dailyData = last7Days.map((day) {
      final total = transactions
          .where((transaction) => transaction.isExpense)
          .where((transaction) {
            return transaction.date.year == day.year &&
                transaction.date.month == day.month &&
                transaction.date.day == day.day;
          })
          .fold(0.0, (sum, transaction) => sum + transaction.amount);
      return _DayPoint(day: day, amount: total);
    }).toList();

    final categoryData = categorySpending.entries.map((entry) {
      final category = categories.firstWhere(
        (item) => item.id == entry.key,
        orElse: () => const Category(
          id: 'other',
          name: 'Other',
          icon: '📦',
          color: AppTheme.mutedForeground,
        ),
      );
      return _CategoryPoint(
        name: category.name.split(' ').first,
        amount: entry.value,
        color: category.color,
        icon: category.icon,
      );
    }).toList()..sort((left, right) => right.amount.compareTo(left.amount));

    final topCategories = categoryData.take(5).toList();
    final savingsRate = monthlyIncome > 0
        ? ((monthlyIncome - monthlyExpenses) / monthlyIncome) * 100
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analytics',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.trending_up,
                label: 'Net Balance',
                value: formatCurrency(
                  monthlyIncome - monthlyExpenses,
                  decimals: 0,
                ),
                valueColor: (monthlyIncome - monthlyExpenses) >= 0
                    ? AppTheme.income
                    : AppTheme.expense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.pie_chart,
                label: 'Savings Rate',
                value: '${savingsRate.toStringAsFixed(0)}%',
                valueColor: AppTheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "This Week's Spending",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: _WeeklyBarChartFL(points: dailyData),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Spending Categories',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              if (topCategories.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No spending data yet',
                    style: TextStyle(color: AppTheme.mutedForeground),
                  ),
                )
              else
                Column(
                  children: [
                    for (final category in topCategories)
                      _CategoryRow(
                        category: category,
                        maxAmount: topCategories.first.amount == 0
                            ? 1
                            : topCategories.first.amount,
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Trend',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: _TrendLineChartFL(points: dailyData),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: valueColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.mutedForeground,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayPoint {
  const _DayPoint({required this.day, required this.amount});

  final DateTime day;
  final double amount;
}

class _CategoryPoint {
  const _CategoryPoint({
    required this.name,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String name;
  final double amount;
  final Color color;
  final String icon;
}

class _WeeklyBarChartFL extends StatelessWidget {
  const _WeeklyBarChartFL({required this.points});

  final List<_DayPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxY = points.isEmpty
        ? 100.0
        : points.map((point) => point.amount).reduce((a, b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        maxY: maxY <= 0 ? 100 : maxY * 1.2,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final point = points[value.toInt()];
                const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labels[(point.day.weekday - 1).clamp(0, 6)],
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var index = 0; index < points.length; index++)
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: points[index].amount,
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                  color: AppTheme.primary,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.maxAmount});

  final _CategoryPoint category;
  final double maxAmount;

  @override
  Widget build(BuildContext context) {
    final progress = maxAmount == 0 ? 0.0 : category.amount / maxAmount;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(category.icon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(formatCurrency(category.amount, decimals: 0)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppTheme.muted,
              color: category.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendLineChartFL extends StatelessWidget {
  const _TrendLineChartFL({required this.points});

  final List<_DayPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxY = points.isEmpty
        ? 100.0
        : points.map((point) => point.amount).reduce((a, b) => a > b ? a : b);
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY <= 0 ? 100 : maxY * 1.2,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    formatMonthDay(points[value.toInt()].day).split(' ').first,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var index = 0; index < points.length; index++)
                FlSpot(index.toDouble(), points[index].amount),
            ],
            color: AppTheme.primary,
            barWidth: 3,
            isCurved: true,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
