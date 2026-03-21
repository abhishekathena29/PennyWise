import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryCatalog {
  static const List<Category> categories = [
    Category(
      id: 'food',
      name: 'Food & Dining',
      icon: '🍔',
      color: Color(0xFFF2A23A),
    ),
    Category(
      id: 'transport',
      name: 'Transport',
      icon: '🚗',
      color: Color(0xFF29B6F6),
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      icon: '🛍️',
      color: Color(0xFF7E57C2),
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: '🎬',
      color: Color(0xFFF06292),
    ),
    Category(
      id: 'bills',
      name: 'Bills & Utilities',
      icon: '📱',
      color: Color(0xFF5C6BC0),
    ),
    Category(
      id: 'health',
      name: 'Health',
      icon: '💊',
      color: Color(0xFF24B37E),
    ),
    Category(
      id: 'salary',
      name: 'Salary',
      icon: '💰',
      color: Color(0xFF24B37E),
    ),
    Category(
      id: 'other_income',
      name: 'Other Income',
      icon: '💵',
      color: Color(0xFF2DAE5B),
    ),
  ];
}
