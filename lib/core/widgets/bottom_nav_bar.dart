import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/../app/router.dart';
import '/../app/theme/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.history);
        break;
      case 2:
        context.go(AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: AppColors.bottomNav,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIcon(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            selected: currentIndex == 0,
            onTap: () => _onTap(context, 0),
          ),
          _NavIcon(
            icon: Icons.history,
            selectedIcon: Icons.history,
            selected: currentIndex == 1,
            onTap: () => _onTap(context, 1),
          ),
          _NavIcon(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            selected: currentIndex == 2,
            onTap: () => _onTap(context, 2),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: CircleAvatar(
        radius: 13,
        backgroundColor: selected ? AppColors.primaryButton : Colors.transparent,
        child: Icon(
          selected ? selectedIcon : icon,
          color: AppColors.white,
          size: 20,
        ),
      ),
    );
  }
}