import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';

class PersonView extends StatelessWidget {
  const PersonView({super.key});

  @override
  Widget build(BuildContext context) {
    // To ensure the circle takes up most of the width dynamically
    final double circleDiameter = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      'Face\nRecognition',
                      style: AppTextStyles.font40Bold.copyWith(
                        fontSize: 32, // Adjusted to fit screen nicely
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                
                // Circular Frame (The Core)
                Center(
                  child: Semantics(
                    label: 'Face alignment area',
                    child: Container(
                      width: circleDiameter,
                      height: circleDiameter,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(), // Placeholder for future camera preview
                    ),
                  ),
                ),
                
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                
                // Guide Text
                Center(
                  child: Text(
                    'Align face inside frame:',
                    style: AppTextStyles.font20Regular.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                
                // Action Button
                CustomButton(
                  text: 'Capture',
                  semanticsLabel: 'Take picture of face',
                  backgroundColor: AppColors.primaryButton,
                  onPressed: () {
                    // Capture face logic
                  },
                ),
                
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              ],
            ),
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
          currentIndex: 0, // Match the visual state from other screens
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
