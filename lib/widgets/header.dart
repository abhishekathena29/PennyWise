import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_logo.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.userName,
    required this.onSettingsClick,
    required this.onNotificationsClick,
    required this.onChatClick,
  });

  final String userName;
  final VoidCallback onSettingsClick;
  final VoidCallback onNotificationsClick;
  final VoidCallback onChatClick;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_greeting()}${userName.isNotEmpty ? ', $userName' : ''} 👋',
                    style: const TextStyle(
                      color: AppTheme.mutedForeground,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: const [
                  AppLogo(
                    size: 28,
                    padding: 4,
                    backgroundColor: AppTheme.card,
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'PennyWise',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _IconButton(
                icon: Icons.notifications_none_rounded,
                showDot: true,
                onTap: onNotificationsClick,
              ),
              const SizedBox(width: 8),
              _IconButton(
                icon: Icons.auto_awesome_rounded,
                onTap: onChatClick,
                iconColor: AppTheme.primary,
                highlighted: true,
              ),
              const SizedBox(width: 8),
              _IconButton(
                icon: Icons.settings_outlined,
                onTap: onSettingsClick,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
    this.iconColor,
    this.highlighted = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;
  final Color? iconColor;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: highlighted
              ? AppTheme.primary.withValues(alpha: 0.1)
              : AppTheme.card,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: highlighted
                ? AppTheme.primary.withValues(alpha: 0.25)
                : AppTheme.border,
          ),
          boxShadow: highlighted
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: iconColor ?? AppTheme.foreground,
            ),
            if (showDot)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppTheme.expense,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.card, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
