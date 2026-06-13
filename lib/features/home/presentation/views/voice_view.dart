import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';

class VoiceView extends StatelessWidget {
  const VoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.horizontalPadding,
                right: AppConstants.horizontalPadding,
                top: 16.0,
              ),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Go back',
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            
            // Voice Circle
            Center(
              child: Semantics(
                label: 'Microphone indicator',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.homeSecondaryColor,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.micCircleColor,
                    ),
                    child: const Icon(
                      Icons.mic_none,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            
            // Status Button
            Semantics(
              label: 'Status: Processing',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryButton,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Processing',
                  style: AppTextStyles.font20Regular.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            
            // The Result Box (Centerpiece)
            Expanded(
              child: Semantics(
                label: 'AI Response Box',
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What I Found :',
                          style: AppTextStyles.font20Regular.copyWith(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'The image shows a wooden desk with a black laptop, a white ceramic coffee mug, and a small potted green plant next to the keyboard.',
                          style: AppTextStyles.font20Regular.copyWith(
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            
            // Action Buttons (Bottom Row)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Stop',
                      semanticsLabel: 'Stop processing',
                      backgroundColor: AppColors.stopAction,
                      onPressed: () {
                        // Stop action logic
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CustomButton(
                      text: 'Repeat',
                      semanticsLabel: 'Repeat response',
                      backgroundColor: AppColors.repeatAction,
                      onPressed: () {
                        // Repeat action logic
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          ],
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
          currentIndex: 0, // Hardcoded for demo purposes
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
