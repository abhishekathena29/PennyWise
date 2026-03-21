import 'package:flutter/material.dart';

import '../../../widgets/goal_progress.dart';
import '../../../widgets/quick_stats.dart';
import '../../../widgets/safe_to_spend_card.dart';
import '../../../widgets/spending_chart.dart';
import '../../../widgets/transaction_list.dart';
import '../../goals/models/savings_goal.dart';
import '../../transactions/models/category.dart';
import '../../transactions/models/transaction.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({
    super.key,
    required this.safeToSpend,
    required this.todaySpent,
    required this.dailySavingsRequired,
    required this.goalReserveThisMonth,
    required this.daysLeftInMonth,
    required this.monthlyBudget,
    required this.monthlySpent,
    required this.income,
    required this.expenses,
    required this.savings,
    required this.goalsProgress,
    required this.categorySpending,
    required this.categories,
    required this.goals,
    required this.onAddGoal,
    required this.onContribute,
    required this.transactions,
    required this.onSeeAll,
    required this.onDeleteTransaction,
  });

  final double safeToSpend;
  final double todaySpent;
  final double dailySavingsRequired;
  final double goalReserveThisMonth;
  final int daysLeftInMonth;
  final double monthlyBudget;
  final double monthlySpent;
  final double income;
  final double expenses;
  final double savings;
  final int goalsProgress;
  final Map<String, double> categorySpending;
  final List<Category> categories;
  final List<SavingsGoal> goals;
  final VoidCallback onAddGoal;
  final ValueChanged<SavingsGoal> onContribute;
  final List<Transaction> transactions;
  final VoidCallback onSeeAll;
  final ValueChanged<String> onDeleteTransaction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafeToSpendCard(
          safeToSpend: safeToSpend,
          todaySpent: todaySpent,
          dailySavingsRequired: dailySavingsRequired,
          goalReserveThisMonth: goalReserveThisMonth,
          daysLeftInMonth: daysLeftInMonth,
          monthlyBudget: monthlyBudget,
          monthlySpent: monthlySpent,
        ),
        const SizedBox(height: 20),
        QuickStats(
          income: income,
          expenses: expenses,
          savings: savings,
          goalsProgress: goalsProgress,
        ),
        const SizedBox(height: 20),
        SpendingChart(
          categorySpending: categorySpending,
          categories: categories,
        ),
        const SizedBox(height: 20),
        GoalProgress(
          goals: goals,
          onAddGoal: onAddGoal,
          onContribute: onContribute,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
        TransactionList(
          transactions: transactions,
          categories: categories,
          onDelete: onDeleteTransaction,
        ),
      ],
    );
  }
}
