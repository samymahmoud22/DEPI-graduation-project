import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

class ScanObjectView extends StatelessWidget {
  const ScanObjectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Standard padding as requested
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              
              // Top Navigation Bar (Header)
              Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  button: true,
                  label: 'Back',
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              
              // Camera Preview Container (Main Element)
              Expanded(
                child: Semantics(
                  label: 'Camera Viewfinder Preview',
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white, // Using solid white for the preview placeholder
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const SizedBox(), // Placeholder for future camera preview
                  ),
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              
              // Text Output Section
              Center(
                child: Text(
                  'Object detected:',
                  style: AppTextStyles.font20Regular.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              
              // Action Button
              CustomButton(
                text: 'Capture',
                semanticsLabel: 'Take picture of object',
                backgroundColor: AppColors.primaryButton,
                onPressed: () {
                  // Future logic for capturing an image
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
          currentIndex: 0, // Standard home selected
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
