import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.transactions,
    required this.categories,
    required this.onDelete,
  });

  final List<Transaction> transactions;
  final List<Category> categories;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No transactions yet',
            style: TextStyle(color: AppTheme.mutedForeground),
          ),
        ),
      );
    }

    final grouped = <DateTime, List<Transaction>>{};
    for (final tx in transactions) {
      final key = DateTime(tx.date.year, tx.date.month, tx.date.day);
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    for (final list in grouped.values) {
      list.sort((a, b) => b.date.compareTo(a.date));
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        for (final key in sortedKeys)
          _TransactionDayGroup(
            date: key,
            transactions: grouped[key]!,
            categories: categories,
            onDelete: onDelete,
          ),
      ],
    );
  }
}

class _TransactionDayGroup extends StatelessWidget {
  const _TransactionDayGroup({
    required this.date,
    required this.transactions,
    required this.categories,
    required this.onDelete,
  });

  final DateTime date;
  final List<Transaction> transactions;
  final List<Category> categories;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final dailyTotal = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDateLabel(date),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '-${formatCurrency(dailyTotal, decimals: 2)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.expense,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              for (final tx in transactions)
                _TransactionTile(
                  transaction: tx,
                  category: _categoryFor(tx, categories),
                  onDelete: onDelete,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Category _categoryFor(Transaction tx, List<Category> categories) {
    return categories.firstWhere(
      (c) => c.id == tx.categoryId,
      orElse: () => categories.first,
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.category,
    required this.onDelete,
  });

  final Transaction transaction;
  final Category category;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(category.icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (transaction.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.note,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.mutedForeground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isExpense ? '-' : '+'}${formatCurrency(transaction.amount, decimals: 2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: transaction.isExpense
                      ? AppTheme.expense
                      : AppTheme.income,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatTime(transaction.date),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: () => onDelete(transaction.id),
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: AppTheme.expense,
            ),
          ),
        ],
      ),
    );
  }
}
