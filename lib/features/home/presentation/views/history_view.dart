import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/app_constants.dart';


class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  Widget _buildHistoryCard({
    required IconData icon,
    required String title,
    required String semanticsLabel,
  }) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.homeSecondaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(width: 16), // Gap between icon and text
            Text(
              title,
              style: AppTextStyles.font20Regular.copyWith(
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ],
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
                      padding: const EdgeInsets.only(right: 32.0), // Balance the back button
                      child: Text(
                        'History',
                        style: AppTextStyles.font40Bold.copyWith(
                          fontSize: 32,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              
              // History List
              _buildHistoryCard(
                icon: Icons.article_outlined,
                title: 'Text',
                semanticsLabel: 'View text history',
              ),
              const SizedBox(height: 20),
              
              _buildHistoryCard(
                icon: Icons.person_outline,
                title: 'Person',
                semanticsLabel: 'View person history',
              ),
              const SizedBox(height: 20),
              
              _buildHistoryCard(
                icon: Icons.camera_alt_outlined,
                title: 'Object',
                semanticsLabel: 'View object history',
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
