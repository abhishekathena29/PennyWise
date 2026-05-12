import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/gemini_service.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../models/savings_goal.dart';
import '../providers/goals_provider.dart';

class GoalsView extends StatefulWidget {
  const GoalsView({
    super.key,
    required this.goals,
    required this.onAddGoal,
    required this.onContribute,
    required this.onDeleteGoal,
  });

  final List<SavingsGoal> goals;
  final VoidCallback onAddGoal;
  final ValueChanged<SavingsGoal> onContribute;
  final ValueChanged<String> onDeleteGoal;

  @override
  State<GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> {
  String? _aiAdvice;
  bool _isLoadingAdvice = false;
  String? _adviceError;

  Future<void> _generateAdvice() async {
    setState(() {
      _isLoadingAdvice = true;
      _adviceError = null;
    });

    try {
      final gemini = context.read<GeminiService>();
      final transactions = context.read<TransactionsProvider>();
      await gemini.ensureInitialized();

      if (!gemini.isInitialized) {
        setState(() {
          _adviceError = gemini.initError;
          _isLoadingAdvice = false;
        });
        return;
      }
      final goalMaps = widget.goals
          .map(
            (g) => {
              'name': g.name,
              'target': g.targetAmount.toStringAsFixed(0),
              'current': g.currentAmount.toStringAsFixed(0),
              'deadline': g.deadline.toIso8601String().split('T').first,
              'priority': g.priority.name,
            },
          )
          .toList();

      final advice = await gemini.analyzeGoals(
        goals: goalMaps,
        monthlyIncome: transactions.monthlyIncome,
        monthlyExpenses: transactions.monthlyExpenses,
      );

      if (mounted) {
        setState(() {
          _aiAdvice = advice;
          _isLoadingAdvice = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _adviceError = 'Failed to generate advice: $e';
          _isLoadingAdvice = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalsProvider = context.watch<GoalsProvider>();
    final totalSaved =
        widget.goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
    final totalTarget =
        widget.goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
    final overallProgress =
        totalTarget > 0 ? (totalSaved / totalTarget) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Savings Goals',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.foreground,
                letterSpacing: -0.4,
              ),
            ),
            GestureDetector(
              onTap: widget.onAddGoal,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'New Goal',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (widget.goals.isNotEmpty)
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.flag,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Savings Progress',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${widget.goals.length} active goals',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Saved',
                      style: TextStyle(color: AppTheme.mutedForeground),
                    ),
                    Text(
                      '${formatCurrency(totalSaved, decimals: 0)} / ${formatCurrency(totalTarget, decimals: 0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (overallProgress / 100).clamp(0, 1),
                    minHeight: 10,
                    backgroundColor: AppTheme.muted,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${overallProgress.toStringAsFixed(0)}% of your goals achieved',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        if (widget.goals.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF10221F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Auto Goal Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'To stay on track, reserve ${formatCurrency(goalsProvider.dailySavingsRequired, decimals: 0)} per day or ${formatCurrency(goalsProvider.monthlySavingsRequired, decimals: 0)} per month.',
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _AiGoalAdviceCard(
            isLoading: _isLoadingAdvice,
            advice: _aiAdvice,
            error: _adviceError,
            onGenerate: _generateAdvice,
          ),
        ],
        const SizedBox(height: 16),
        if (widget.goals.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.flag_outlined,
                  size: 48,
                  color: AppTheme.mutedForeground,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No goals yet',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Start saving towards something meaningful',
                  style: TextStyle(color: AppTheme.mutedForeground),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: widget.onAddGoal,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Create Your First Goal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              for (final goal in widget.goals)
                _GoalCard(
                  goal: goal,
                  plan: goalsProvider.planFor(goal.id),
                  onContribute: () => widget.onContribute(goal),
                  onDelete: () => widget.onDeleteGoal(goal.id),
                ),
            ],
          ),
      ],
    );
  }
}

class _AiGoalAdviceCard extends StatelessWidget {
  const _AiGoalAdviceCard({
    required this.isLoading,
    required this.advice,
    required this.error,
    required this.onGenerate,
  });

  final bool isLoading;
  final String? advice;
  final String? error;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'AI Goal Advisor',
                  style: TextStyle(
                    color: AppTheme.foreground,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              if (advice != null && !isLoading)
                GestureDetector(
                  onTap: onGenerate,
                  child: const Icon(
                    Icons.refresh,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primary,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Analyzing your goals...',
                  style: TextStyle(color: AppTheme.mutedForeground),
                ),
              ],
            )
          else if (error != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error!,
                  style: const TextStyle(
                    color: AppTheme.expense,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onGenerate,
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          else if (advice != null)
            Text(
              advice!,
              style: const TextStyle(
                color: AppTheme.foreground,
                height: 1.5,
                fontSize: 13,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Get personalized tips from Gemini AI on how to reach your goals faster.',
                  style: TextStyle(
                    color: AppTheme.mutedForeground,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onGenerate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Get AI Tips',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.plan,
    required this.onContribute,
    required this.onDelete,
  });

  final SavingsGoal goal;
  final GoalAutomationPlan? plan;
  final VoidCallback onContribute;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final progress = goal.targetAmount == 0
        ? 0.0
        : (goal.currentAmount / goal.targetAmount) * 100;
    final daysLeft =
        plan?.daysLeft ?? goal.deadline.difference(DateTime.now()).inDays;
    final remaining = goal.targetAmount - goal.currentAmount;
    final dailyRequired =
        plan?.dailyContribution ??
        (daysLeft > 0 ? remaining / daysLeft : remaining);
    final isCompleted = goal.currentAmount >= goal.targetAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      child: Stack(
        children: [
          if (isCompleted)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: AppTheme.income,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'Complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Target ${formatCurrency(goal.targetAmount, decimals: 0)}',
                style: const TextStyle(color: AppTheme.mutedForeground),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatCurrency(goal.currentAmount, decimals: 0),
                    style: TextStyle(
                      color: goal.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (progress / 100).clamp(0, 1),
                  minHeight: 10,
                  backgroundColor: AppTheme.muted,
                  color: goal.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                daysLeft >= 0
                    ? '$daysLeft days left • Save ${formatCurrency(dailyRequired, decimals: 0)}/day'
                    : 'Goal date passed • Remaining ${formatCurrency(remaining, decimals: 0)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.mutedForeground,
                ),
              ),
              if (plan != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: goal.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: goal.color, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          plan!.summary,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: goal.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.expense,
                        side: const BorderSide(color: AppTheme.expense),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onContribute,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goal.color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Add Savings'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
