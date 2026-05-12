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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.muted,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppTheme.mutedForeground,
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'No transactions yet',
                style: TextStyle(
                  color: AppTheme.mutedForeground,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
                  fontSize: 11,
                  color: AppTheme.mutedForeground,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              Text(
                '-${formatCurrency(dailyTotal, decimals: 2)}',
                style: const TextStyle(
                  fontSize: 11,
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
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          splashColor: AppTheme.primary.withValues(alpha: 0.05),
          highlightColor: AppTheme.primary.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Text(category.icon, style: const TextStyle(fontSize: 19)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppTheme.foreground,
                        ),
                      ),
                      if (transaction.note.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          transaction.note,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.mutedForeground,
                            height: 1.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
                        fontSize: 13,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatTime(transaction.date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 2),
                GestureDetector(
                  onTap: () => onDelete(transaction.id),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 17,
                      color: AppTheme.mutedForeground.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
