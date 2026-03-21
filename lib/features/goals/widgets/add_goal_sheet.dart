import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/bottom_sheet_container.dart';
import '../../../widgets/input_field.dart';
import '../models/savings_goal.dart';
import '../providers/goals_provider.dart';

class AddGoalSheet extends StatefulWidget {
  const AddGoalSheet({super.key});

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 90));
  GoalPriority _priority = GoalPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final target = double.tryParse(_targetController.text) ?? 0;
    if (_titleController.text.trim().isEmpty || target <= 0) {
      return;
    }

    final goalsProvider = context.read<GoalsProvider>();
    final success = await goalsProvider.addGoal(
      SavingsGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _titleController.text.trim(),
        targetAmount: target,
        currentAmount: 0,
        deadline: _deadline,
        priority: _priority,
        color: goalsProvider.colorForPriority(_priority),
      ),
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
      title: 'Create goal',
      child: Column(
        children: [
          InputField(label: 'Goal name', controller: _titleController),
          const SizedBox(height: 12),
          InputField(
            label: 'Target amount',
            controller: _targetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<GoalPriority>(
            initialValue: _priority,
            decoration: inputDecoration('Priority'),
            items: const [
              DropdownMenuItem(
                value: GoalPriority.high,
                child: Text('High priority'),
              ),
              DropdownMenuItem(
                value: GoalPriority.medium,
                child: Text('Medium priority'),
              ),
              DropdownMenuItem(
                value: GoalPriority.low,
                child: Text('Low priority'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _priority = value);
              }
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: _deadline,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (selected != null) {
                  setState(() => _deadline = selected);
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
                  const Text('Target date'),
                  Text(formatMonthDay(_deadline)),
                ],
              ),
            ),
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
              child: goalsProvider.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Add goal'),
            ),
          ),
        ],
      ),
    );
  }
}
