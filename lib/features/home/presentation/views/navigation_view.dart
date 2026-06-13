import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';

class NavigationView extends StatelessWidget {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              
              // Top Bar & Title
              Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Back',
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // Title
              Center(
                child: Semantics(
                  header: true,
                  child: Text(
                    'Navigation',
                    style: AppTextStyles.font40Bold.copyWith(
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              
              // Search Section
              Semantics(
                label: 'Search destination',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Where do you want to go?',
                          style: AppTextStyles.font20Regular.copyWith(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.mic_none,
                        color: AppColors.background,
                        size: 32,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              
              // Location Label
              Text(
                'Your location',
                style: AppTextStyles.font20Regular.copyWith(
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Map/Location Preview (Placeholder)
              Expanded(
                child: Semantics(
                  label: 'Map preview placeholder',
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const SizedBox(), // Placeholder for future map
                  ),
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              
              // Action Button
              CustomButton(
                text: 'Start Navigation',
                semanticsLabel: 'Start Navigation',
                backgroundColor: AppColors.primaryButton,
                onPressed: () {
                  // Navigation start logic
                },
              ),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            ],
          ),
        ),
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
          currentIndex: 0, 
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
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
            const BottomNavigationBarItem(
              icon: Icon(Icons.history, color: Colors.white),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, color: Colors.white),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
