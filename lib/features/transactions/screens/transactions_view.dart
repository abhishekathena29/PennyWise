import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/transaction_list.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Transactions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.mutedForeground,
                ),
                SizedBox(width: 6),
                Text(
                  'This Month',
                  style: TextStyle(color: AppTheme.mutedForeground),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        TransactionList(
          transactions: transactions,
          categories: categories,
          onDelete: onDelete,
        ),
      ],
    );
  }
}
