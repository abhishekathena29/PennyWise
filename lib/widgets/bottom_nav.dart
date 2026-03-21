import 'package:flutter/material.dart';

import '../models/app_tab.dart';
import '../theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.activeTab,
    required this.onTabChange,
    required this.onAddClick,
  });

  final AppTab activeTab;
  final ValueChanged<AppTab> onTabChange;
  final VoidCallback onAddClick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: AppTheme.card.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: AppTheme.border)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: Icons.home_filled,
                  label: 'Home',
                  isActive: activeTab == AppTab.dashboard,
                  onTap: () => onTabChange(AppTab.dashboard),
                ),
                _NavItem(
                  icon: Icons.receipt_long,
                  label: 'Activity',
                  isActive: activeTab == AppTab.transactions,
                  onTap: () => onTabChange(AppTab.transactions),
                ),
                const SizedBox(width: 56),
                _NavItem(
                  icon: Icons.flag_outlined,
                  label: 'Goals',
                  isActive: activeTab == AppTab.goals,
                  onTap: () => onTabChange(AppTab.goals),
                ),
                _NavItem(
                  icon: Icons.bar_chart,
                  label: 'Stats',
                  isActive: activeTab == AppTab.analytics,
                  onTap: () => onTabChange(AppTab.analytics),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -22),
              child: _FabButton(onTap: onAddClick),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primary : AppTheme.mutedForeground;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  const _FabButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4425B8A3),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
