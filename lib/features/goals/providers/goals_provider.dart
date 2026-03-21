import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

import '../data/goals_repository.dart';
import '../models/savings_goal.dart';

class GoalAutomationPlan {
  const GoalAutomationPlan({
    required this.goalId,
    required this.remainingAmount,
    required this.daysLeft,
    required this.dailyContribution,
    required this.weeklyContribution,
    required this.monthlyContribution,
    required this.isCompleted,
    required this.isOverdue,
  });

  final String goalId;
  final double remainingAmount;
  final int daysLeft;
  final double dailyContribution;
  final double weeklyContribution;
  final double monthlyContribution;
  final bool isCompleted;
  final bool isOverdue;

  String get summary {
    if (isCompleted) {
      return 'Completed';
    }
    if (isOverdue) {
      return 'Past due • add funds to catch up';
    }
    return 'Auto-save ₹${dailyContribution.toStringAsFixed(0)}/day or ₹${monthlyContribution.toStringAsFixed(0)}/month';
  }
}

class GoalsProvider extends ChangeNotifier {
  GoalsProvider(this._repository);

  final GoalsRepository _repository;

  StreamSubscription<List<SavingsGoal>>? _subscription;
  String? _uid;
  List<SavingsGoal> _goals = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<SavingsGoal> get goals => _goals;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> bindUser(auth.User? user) async {
    final nextUid = user?.uid;
    if (_uid == nextUid) {
      return;
    }
    await _subscription?.cancel();
    _uid = nextUid;
    _goals = const [];
    _errorMessage = null;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    _subscription = _repository
        .watchGoals(user.uid)
        .listen(
          (items) {
            _goals = items;
            _isLoading = false;
            notifyListeners();
          },
          onError: (_) {
            _errorMessage = 'Unable to load saving goals right now.';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<bool> addGoal(SavingsGoal goal) async {
    if (_uid == null) {
      return false;
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.addGoal(_uid!, goal);
      return true;
    } catch (_) {
      _errorMessage = 'Unable to save the goal.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    if (_uid == null) {
      return;
    }
    try {
      await _repository.deleteGoal(_uid!, id);
    } catch (_) {
      _errorMessage = 'Unable to delete the goal.';
      notifyListeners();
    }
  }

  Future<bool> contributeToGoal({
    required String goalId,
    required double amount,
  }) async {
    if (_uid == null) {
      return false;
    }
    final goal = _goals.where((item) => item.id == goalId).firstOrNull;
    if (goal == null) {
      return false;
    }
    try {
      await _repository.updateGoalAmount(
        uid: _uid!,
        goalId: goalId,
        currentAmount: min(goal.targetAmount, goal.currentAmount + amount),
      );
      return true;
    } catch (_) {
      _errorMessage = 'Unable to add contribution.';
      notifyListeners();
      return false;
    }
  }

  double get totalSaved =>
      _goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
  double get totalTarget =>
      _goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
  List<GoalAutomationPlan> get automationPlans =>
      _goals.map(_buildPlan).toList();

  int get goalsProgressPercent {
    if (totalTarget == 0) {
      return 0;
    }
    return ((totalSaved / totalTarget) * 100).round();
  }

  double get dailySavingsRequired {
    final now = DateTime.now();
    var totalRequired = 0.0;
    for (final goal in _goals) {
      final remaining = max(0.0, goal.targetAmount - goal.currentAmount);
      final daysToDeadline = max(1, goal.deadline.difference(now).inDays);
      totalRequired += remaining / daysToDeadline;
    }
    return totalRequired;
  }

  double get monthlySavingsRequired => dailySavingsRequired * 30;

  GoalAutomationPlan? planFor(String goalId) {
    final goal = _goals.where((item) => item.id == goalId).firstOrNull;
    if (goal == null) {
      return null;
    }
    return _buildPlan(goal);
  }

  GoalAutomationPlan _buildPlan(SavingsGoal goal) {
    final now = DateTime.now();
    final remaining = max(0.0, goal.targetAmount - goal.currentAmount);
    final daysLeft = max(0, goal.deadline.difference(now).inDays);
    final safeDays = max(1, daysLeft);
    return GoalAutomationPlan(
      goalId: goal.id,
      remainingAmount: remaining,
      daysLeft: daysLeft,
      dailyContribution: remaining / safeDays,
      weeklyContribution: (remaining / safeDays) * 7,
      monthlyContribution: (remaining / safeDays) * 30,
      isCompleted: remaining == 0,
      isOverdue: daysLeft == 0 && remaining > 0,
    );
  }

  Color colorForPriority(GoalPriority priority) {
    switch (priority) {
      case GoalPriority.high:
        return const Color(0xFFF06292);
      case GoalPriority.medium:
        return const Color(0xFF25B8A3);
      case GoalPriority.low:
        return const Color(0xFF29B6F6);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
