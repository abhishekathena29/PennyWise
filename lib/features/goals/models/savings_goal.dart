import 'package:flutter/material.dart';

enum GoalPriority { low, medium, high }

class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.priority,
    required this.color,
  });

  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final GoalPriority priority;
  final Color color;

  SavingsGoal copyWith({
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    GoalPriority? priority,
    Color? color,
  }) {
    return SavingsGoal(
      id: id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline.toUtc().millisecondsSinceEpoch,
      'priority': priority.name,
      'color': color.toARGB32(),
    };
  }

  factory SavingsGoal.fromMap(String id, Map<String, dynamic> map) {
    final priorityName = map['priority'] as String? ?? GoalPriority.medium.name;
    return SavingsGoal(
      id: id,
      name: map['name'] as String? ?? '',
      targetAmount: (map['targetAmount'] as num? ?? 0).toDouble(),
      currentAmount: (map['currentAmount'] as num? ?? 0).toDouble(),
      deadline: DateTime.fromMillisecondsSinceEpoch(
        (map['deadline'] as num?)?.toInt() ?? 0,
        isUtc: true,
      ).toLocal(),
      priority: GoalPriority.values.firstWhere(
        (value) => value.name == priorityName,
        orElse: () => GoalPriority.medium,
      ),
      color: Color(
        (map['color'] as num?)?.toInt() ?? const Color(0xFF25B8A3).toARGB32(),
      ),
    );
  }
}
