import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/bottom_sheet_container.dart';
import '../../../widgets/input_field.dart';
import '../models/savings_goal.dart';
import '../providers/goals_provider.dart';

class ContributeSheet extends StatefulWidget {
  const ContributeSheet({super.key, required this.goal});

  final SavingsGoal goal;

  @override
  State<ContributeSheet> createState() => _ContributeSheetState();
}

class _ContributeSheetState extends State<ContributeSheet> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      return;
    }
    final success = await context.read<GoalsProvider>().contributeToGoal(
      goalId: widget.goal.id,
      amount: amount,
    );
    if (!mounted || !success) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final goalsProvider = context.watch<GoalsProvider>();

    return BottomSheetContainer(
      title: 'Contribute to ${widget.goal.name}',
      child: Column(
        children: [
          InputField(
            label: 'Amount',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          if (goalsProvider.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              goalsProvider.errorMessage!,
              style: const TextStyle(color: AppTheme.expense, fontSize: 12),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: goalsProvider.isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Add contribution'),
            ),
          ),
        ],
      ),
    );
  }
}
