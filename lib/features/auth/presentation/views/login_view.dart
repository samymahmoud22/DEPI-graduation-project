import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../home/presentation/views/main_view.dart';
import 'sign_up_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

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
                    'Login',
                    style: AppTextStyles.font40Bold,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.verticalSpace50),
              
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
              
              const SizedBox(height: AppConstants.verticalSpace10),
              
              Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  button: true,
                  label: 'Forgot Password button',
                  child: GestureDetector(
                    onTap: () {
                      // Placeholder for forgot password logic
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.font20Regular.copyWith(
                        color: AppColors.forgotPasswordColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.verticalSpace40),
              
              CustomButton(
                text: 'Login',
                semanticsLabel: 'Login button',
                backgroundColor: AppColors.primaryButton,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainView()),
                  );
                },
              ),
              
              const SizedBox(height: AppConstants.verticalSpace15),
              
              CustomButton(
                text: 'Continue as Guest',
                semanticsLabel: 'Continue as Guest button',
                backgroundColor: AppColors.primaryButton,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainView()),
                  );
                },
              ),
              
              const SizedBox(height: AppConstants.verticalSpace150),
              
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: AppTextStyles.font20Regular,
                    ),
                    const SizedBox(height: AppConstants.verticalSpace8),
                    Semantics(
                      button: true,
                      label: 'Navigate to Sign Up screen',
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpView()),
                          );
                        },
                        child: Text(
                          'Sign Up',
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
