import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_feedback_snackbar.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/app_logo.dart';
import '../../auth/providers/auth_provider.dart';
import '../../goals/providers/goals_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../transactions/providers/transactions_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _editName(BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final profileProvider = context.read<ProfileProvider>();
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (shouldSave != true || !mounted) {
      return;
    }
    await profileProvider.updateName(controller.text.trim());
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final transactionsProvider = context.read<TransactionsProvider>();
    final goalsProvider = context.read<GoalsProvider>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently removes your account and clears your saved profile, transactions, and goals.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) {
      return;
    }

    final result = await authProvider.deleteAccount(
      transactionIds: transactionsProvider.transactions.map((item) => item.id),
      goalIds: goalsProvider.goals.map((item) => item.id),
    );
    if (!context.mounted) {
      return;
    }
    if (result.isSuccess) {
      Navigator.of(context).pop();
      AppFeedbackSnackBar.show(
        context: context,
        title: 'Account deleted',
        message: 'Your PennyWise account has been removed.',
        icon: Icons.delete_forever_outlined,
        color: AppTheme.expense,
      );
      return;
    }
    final feedback = result.feedback ?? authProvider.lastFeedback;
    if (feedback != null && context.mounted) {
      AppFeedbackSnackBar.show(
        context: context,
        title: feedback.title,
        message: feedback.message,
        icon: feedback.icon,
        color: feedback.color,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final transactionsProvider = context.watch<TransactionsProvider>();
    final goalsProvider = context.watch<GoalsProvider>();
    final profile = profileProvider.profile;

    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 20,
              right: 16,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: AppTheme.darkGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const AppLogo(
                    size: 80,
                    padding: 12,
                    backgroundColor: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  (profile?.name.isNotEmpty ?? false) ? profile!.name : 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile?.email ?? '',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile?.createdAt != null
                        ? 'Member since ${formatMonthDay(profile!.createdAt!)}'
                        : 'Firebase profile',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: 'This Month',
                            value: formatCurrency(
                              transactionsProvider.monthlyIncome -
                                  transactionsProvider.monthlyExpenses,
                              decimals: 0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _StatTile(
                            label: 'Expenses',
                            value: formatCurrency(
                              transactionsProvider.monthlyExpenses,
                              decimals: 0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _StatTile(
                            label: 'Goals',
                            value: '${goalsProvider.goalsProgressPercent}%',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      'PROFILE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.mutedForeground,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  _SettingRow(
                    item: _SettingItem(
                      icon: Icons.person_outline,
                      label: 'Edit Profile',
                      subtitle: 'Update your display name',
                      color: const Color(0xFF25B8A3),
                      onTap:
                          profile == null ? null : () => _editName(context, profile.name),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileStatCard(
                          icon: Icons.receipt_long,
                          label: 'Transactions',
                          value: '${transactionsProvider.transactions.length}',
                          color: const Color(0xFF29B6F6),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ProfileStatCard(
                          icon: Icons.flag_outlined,
                          label: 'Saving Goals',
                          value: '${goalsProvider.goals.length}',
                          color: const Color(0xFFF2A23A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ProfileStatCard(
                          icon: Icons.savings_outlined,
                          label: 'Saved So Far',
                          value: formatCompactCurrency(goalsProvider.totalSaved),
                          color: const Color(0xFF24B37E),
                        ),
                      ),
                    ],
                  ),
                  if (profileProvider.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      profileProvider.errorMessage!,
                      style: const TextStyle(
                        color: AppTheme.expense,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: authProvider.isDeletingAccount
                        ? null
                        : () => _deleteAccount(context),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.expense.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.expense.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: authProvider.isDeletingAccount
                                ? const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.expense,
                                    ),
                                  )
                                : const Icon(
                                    Icons.delete_outline,
                                    color: AppTheme.expense,
                                    size: 20,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delete Account',
                                style: TextStyle(
                                  color: AppTheme.expense,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Permanently remove your account and saved data',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      await authProvider.signOut();
                      if (mounted) {
                        navigator.pop();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.expense.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.expense.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: AppTheme.expense,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Log Out',
                                style: TextStyle(
                                  color: AppTheme.expense,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Your Firebase session will end',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.mutedForeground),
        ),
      ],
    );
  }
}

class _SettingItem {
  const _SettingItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.item});

  final _SettingItem item;

  @override
  Widget build(BuildContext context) {
    final isInteractive = item.onTap != null;
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (isInteractive)
              const Icon(Icons.chevron_right, color: AppTheme.mutedForeground),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
