import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SettingsRow extends StatelessWidget {
  const SettingsRow({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.mutedForeground),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppTheme.mutedForeground),
        ],
      ),
    );
  }
}
