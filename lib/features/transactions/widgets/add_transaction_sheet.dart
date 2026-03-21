import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/bottom_sheet_container.dart';
import '../../../widgets/input_field.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/transactions_provider.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key, required this.categories});

  final List<Category> categories;

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isExpense = true;
  late Category _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categories.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || _selectedCategory.id.isEmpty) {
      return;
    }

    final success = await context.read<TransactionsProvider>().addTransaction(
      Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: _selectedCategory.id,
        amount: amount,
        date: _selectedDate,
        isExpense: _isExpense,
        note: _noteController.text.trim(),
      ),
    );
    if (!mounted || !success) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = widget.categories.where((category) {
      if (_isExpense) {
        return !category.isIncomeCategory;
      }
      return category.isIncomeCategory;
    }).toList();
    if (filteredCategories.isNotEmpty &&
        !filteredCategories.contains(_selectedCategory)) {
      _selectedCategory = filteredCategories.first;
    }

    final transactionsProvider = context.watch<TransactionsProvider>();

    return BottomSheetContainer(
      title: 'Add transaction',
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isExpense = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isExpense ? AppTheme.expense : AppTheme.muted,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove,
                          size: 16,
                          color: _isExpense
                              ? Colors.white
                              : AppTheme.mutedForeground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Expense',
                          style: TextStyle(
                            color: _isExpense
                                ? Colors.white
                                : AppTheme.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isExpense = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isExpense ? AppTheme.income : AppTheme.muted,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 16,
                          color: !_isExpense
                              ? Colors.white
                              : AppTheme.mutedForeground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Income',
                          style: TextStyle(
                            color: !_isExpense
                                ? Colors.white
                                : AppTheme.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Amount',
              style: TextStyle(
                color: AppTheme.mutedForeground,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '₹ ',
              hintText: '0.00',
              filled: true,
              fillColor: AppTheme.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
            ),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Category',
              style: TextStyle(
                color: AppTheme.mutedForeground,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in filteredCategories)
                GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    width: 72,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedCategory.id == category.id
                          ? category.color.withValues(alpha: 0.15)
                          : AppTheme.muted,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedCategory.id == category.id
                            ? category.color
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          category.icon,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.name.split(' ').first,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          InputField(label: 'Note (optional)', controller: _noteController),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selected != null) {
                  setState(() => _selectedDate = selected);
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: const BorderSide(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Date'),
                  Text(formatMonthDay(_selectedDate)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (transactionsProvider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                transactionsProvider.errorMessage!,
                style: const TextStyle(color: AppTheme.expense, fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: transactionsProvider.isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: transactionsProvider.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_isExpense ? 'Add Expense' : 'Add Income'),
            ),
          ),
        ],
      ),
    );
  }
}
