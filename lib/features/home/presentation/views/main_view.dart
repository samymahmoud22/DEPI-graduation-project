import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'history_view.dart';
import 'home_view.dart';
import 'settings_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeView(),
    const HistoryView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.homeSecondaryColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined, color: Colors.white),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryButton,
                ),
                child: const Icon(Icons.home_outlined, color: Colors.white),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history, color: Colors.white),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryButton,
                ),
                child: const Icon(Icons.history, color: Colors.white),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryButton,
                ),
                child: const Icon(Icons.settings_outlined, color: Colors.white),
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
