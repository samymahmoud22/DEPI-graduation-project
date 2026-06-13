import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../auth/presentation/views/login_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: AppTextStyles.font20Regular.copyWith(
          fontWeight: FontWeight.normal,
          color: Colors.white,
          fontSize: 26, // Slightly larger and normal weight
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String semanticsLabel,
    IconData? leftIcon,
    double leftIconSize = 28,
    IconData? rightIcon,
    VoidCallback? onTap,
  }) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.homeSecondaryColor,
            borderRadius: BorderRadius.circular(AppConstants.cardRadius), 
          ),
          child: Row(
            children: [
              if (leftIcon != null) ...[
                Icon(leftIcon, size: leftIconSize, color: Colors.white),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.font20Regular.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
              if (rightIcon != null) ...[
                Icon(rightIcon, size: 24, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }

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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 32.0),
                      child: Text(
                        'Setting',
                        style: AppTextStyles.font40Bold.copyWith(
                          fontSize: 32,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              
              // Language Section
              _buildSectionTitle('Language'),
              _buildSettingsCard(
                title: 'English',
                semanticsLabel: 'Select Language: English',
                leftIcon: Icons.circle,
                leftIconSize: 12, // Small bullet on the left
              ),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              
              // Account Section
              _buildSectionTitle('Account'),
              _buildSettingsCard(
                title: 'Profile',
                semanticsLabel: 'View Profile',
                leftIcon: Icons.person_outline,
              ),
              _buildSettingsCard(
                title: 'LogOut',
                semanticsLabel: 'Log out of account',
                leftIcon: Icons.person_outline,
                onTap: () {
                  // Navigate to LoginView and remove all previous routes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                    (route) => false,
                  );
                },
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
