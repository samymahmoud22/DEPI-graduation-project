import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/app_constants.dart';

import 'navigation_view.dart';
import 'person_view.dart';
import 'scan_object_view.dart';


class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03), // Reduced top spacing
              
              // Header
              Semantics(
                header: true,
                child: Text(
                  'Hello, samy',
                  style: AppTextStyles.font40Bold.copyWith(fontSize: 32), // Downsized title slightly
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'What would you like to do today?',
                style: AppTextStyles.font20Regular.copyWith(fontSize: 16), // Downsized subtitle slightly
              ),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.03), // Reduced spacing
              
              // Voice Assistant Section
              Center(
                child: Column(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Microphone button to speak',
                      child: GestureDetector(
                        onTap: () {
                          // Currently unbound
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16), // Reduced outer padding
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.homeSecondaryColor, 
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(24), // Reduced inner padding
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.micCircleColor, 
                            ),
                            child: const Icon(
                              Icons.mic_none, // Outlined mic icon
                              size: 48, // Reduced icon size
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // Reduced gap
                    Semantics(
                      button: true,
                      label: 'Tap to Speak button',
                      child: GestureDetector(
                        onTap: () {
                          // Currently unbound
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), // Reduced button padding
                          decoration: BoxDecoration(
                            color: AppColors.primaryButton,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'Tap to Speak',
                            style: AppTextStyles.font20Regular.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 16, // Reduced text size
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              
              // Features Grid (Strict 2x2 Implementation using Rows/Columns)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.camera_alt_outlined,
                          title: 'Scan Object',
                          semanticsLabel: 'Scan Object feature',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ScanObjectView()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16), // Reduced column spacing
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.article_outlined,
                          title: 'Read Text',
                          semanticsLabel: 'Read Text feature',
                          onTap: () {
                            Navigator.pushNamed(context, '/voiceView');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Reduced row spacing
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.person_outline,
                          title: 'Person',
                          semanticsLabel: 'Person recognition feature',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PersonView()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16), // Reduced column spacing
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.location_on_outlined,
                          title: 'Location',
                          semanticsLabel: 'Location feature',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NavigationView()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16), // Reduced bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String semanticsLabel,
    VoidCallback? onTap,
  }) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16), // Reduced padding to make cards compact
          decoration: BoxDecoration(
            color: AppColors.homeSecondaryColor,
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36, // Reduced icon size
                color: Colors.white,
              ),
              const SizedBox(height: 8), // Reduced gap
              Text(
                title,
                style: AppTextStyles.font20Regular.copyWith(
                  fontWeight: FontWeight.normal,
                  fontSize: 16, // Downsized text to fit tightly
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
