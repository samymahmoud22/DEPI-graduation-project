import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../home/presentation/views/main_view.dart';


class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppConstants.topSpacing(context)),
              
              Center(
                child: Semantics(
                  header: true,
                  child: const Text(
                    'Sign Up',
                    style: AppTextStyles.font40Bold,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.verticalSpace50),
              
              const CustomTextField(
                hintText: 'Name',
                semanticsLabel: 'Name input field',
                keyboardType: TextInputType.name,
              ),
              
              const SizedBox(height: AppConstants.verticalSpace20),
              
              const CustomTextField(
                hintText: 'Email',
                semanticsLabel: 'Email input field',
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: AppConstants.verticalSpace20),
              
              const CustomTextField(
                hintText: 'Password',
                semanticsLabel: 'Password input field',
                obscureText: true,
              ),
              
              const SizedBox(height: AppConstants.verticalSpace20),
              
              const CustomTextField(
                hintText: 'Confirm Password',
                semanticsLabel: 'Confirm Password input field',
                obscureText: true,
              ),
              
              const SizedBox(height: AppConstants.verticalSpace40),
              
              CustomButton(
                text: 'Sign Up',
                semanticsLabel: 'Sign Up button',
                backgroundColor: AppColors.primaryButton,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainView()),
                  );
                },
              ),
              
              const SizedBox(height: AppConstants.verticalSpace100),
              
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: AppTextStyles.font20Regular,
                    ),
                    const SizedBox(height: AppConstants.verticalSpace8),
                    Semantics(
                      button: true,
                      label: 'Navigate back to Login screen',
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Login',
                          style: AppTextStyles.font20Regular.copyWith(
                            color: AppColors.linkColor,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppConstants.verticalSpace30),
            ],
          ),
        ),
      ),
    );
  }
}
