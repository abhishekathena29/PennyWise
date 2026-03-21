import 'package:flutter/material.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String icon;
  final Color color;

  bool get isIncomeCategory {
    final nameLower = name.toLowerCase();
    return nameLower.contains('salary') || nameLower.contains('income');
  }
}
