import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../sheets/notifications_sheet.dart';
import '../../../utils/slide_route.dart';
import '../../../widgets/bottom_nav.dart';
import '../../../widgets/header.dart';
import '../../analytics/screens/analytics_view.dart';
import '../../goals/models/savings_goal.dart';
import '../../goals/providers/goals_provider.dart';
import '../../goals/screens/goals_view.dart';
import '../../goals/widgets/add_goal_sheet.dart';
import '../../goals/widgets/contribute_sheet.dart';
import '../../home/models/app_tab.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/screens/settings_page.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../transactions/screens/transactions_view.dart';
import '../../transactions/widgets/add_transaction_sheet.dart';
import 'dashboard_view.dart';

class HomeController extends StatefulWidget {
  const HomeController({super.key});

  @override
  State<HomeController> createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  AppTab _activeTab = AppTab.dashboard;

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final transactionsProvider = context.watch<TransactionsProvider>();
    final goalsProvider = context.watch<GoalsProvider>();
    final profile = profileProvider.profile;

    final content = switch (_activeTab) {
      AppTab.dashboard => DashboardView(
        safeToSpend: transactionsProvider.safeToSpendToday(
          goalsProvider.dailySavingsRequired,
        ),
        todaySpent: transactionsProvider.todayExpenses,
        dailySavingsRequired: goalsProvider.dailySavingsRequired,
        goalReserveThisMonth: transactionsProvider.goalReserveForRemainingMonth(
          goalsProvider.dailySavingsRequired,
        ),
        daysLeftInMonth: transactionsProvider.daysLeftInMonth,
        monthlyBudget: transactionsProvider.monthlyIncome,
        monthlySpent: transactionsProvider.monthlyExpenses,
        income: transactionsProvider.monthlyIncome,
        expenses: transactionsProvider.monthlyExpenses,
        savings:
            (transactionsProvider.monthlyIncome -
                    transactionsProvider.monthlyExpenses)
                .clamp(0, double.infinity),
        goalsProgress: goalsProvider.goalsProgressPercent,
        categorySpending: transactionsProvider.categorySpending,
        categories: transactionsProvider.categories,
        goals: goalsProvider.goals,
        onAddGoal: () => _openAddGoal(context),
        onContribute: (goal) => _openContribute(context, goal),
        transactions: transactionsProvider.transactions.take(5).toList(),
        onSeeAll: () => setState(() => _activeTab = AppTab.transactions),
        onDeleteTransaction: transactionsProvider.deleteTransaction,
      ),
      AppTab.transactions => TransactionsView(
        transactions: transactionsProvider.transactions,
        categories: transactionsProvider.categories,
        onDelete: transactionsProvider.deleteTransaction,
      ),
      AppTab.goals => GoalsView(
        goals: goalsProvider.goals,
        onAddGoal: () => _openAddGoal(context),
        onContribute: (goal) => _openContribute(context, goal),
        onDeleteGoal: goalsProvider.deleteGoal,
      ),
      AppTab.analytics => AnalyticsView(
        transactions: transactionsProvider.transactions,
        categories: transactionsProvider.categories,
        categorySpending: transactionsProvider.categorySpending,
        monthlyIncome: transactionsProvider.monthlyIncome,
        monthlyExpenses: transactionsProvider.monthlyExpenses,
      ),
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Header(
              userName: profile?.name ?? '',
              onSettingsClick: () => _openSettings(context),
              onNotificationsClick: () => _openNotifications(context),
            ),
            if (transactionsProvider.errorMessage != null ||
                goalsProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    transactionsProvider.errorMessage ??
                        goalsProvider.errorMessage ??
                        '',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                child: content,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        activeTab: _activeTab,
        onTabChange: (tab) => setState(() => _activeTab = tab),
        onAddClick: () => _openAddTransaction(context),
      ),
    );
  }

  void _openAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionSheet(
        categories: context.read<TransactionsProvider>().categories,
      ),
    );
  }

  void _openAddGoal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddGoalSheet(),
    );
  }

  void _openContribute(BuildContext context, SavingsGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ContributeSheet(goal: goal),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(SlideRoute(page: const SettingsPage()));
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(SlideRoute(page: const NotificationsPage()));
  }
}
