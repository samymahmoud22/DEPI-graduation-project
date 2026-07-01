import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/locale_provider.dart';
import '../controller/signup_controller.dart';
import '../widgets/auth_header.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final controller = ref.read(signupControllerProvider);
    final t = ref.read(translationsProvider);

    final success = await controller.signup(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigate to email verification screen instead of home
      context.go(
        '${AppRoutes.emailVerification}?email=${Uri.encodeComponent(emailController.text.trim())}',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? t.get('signup_failed')),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  void _goToLogin() => context.pop();

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(signupControllerProvider);
    final t = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 18),
              AuthHeader(title: t.get('signup')),
              const Spacer(flex: 2),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(hintText: t.get('name')),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: t.get('email')),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                style: const TextStyle(color: Colors.black),
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: t.get('password'),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                style: const TextStyle(color: Colors.black),
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: t.get('confirm_password'),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 34),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: controller.isLoading ? null : _signup,
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(t.get('signup')),
                ),
              ),
              const Spacer(flex: 4),
              Text(
                t.get('have_account'),
                style: AppTextStyles.bodyLarge,
              ),
              TextButton(
                onPressed: _goToLogin,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 26),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  t.get('login'),
                  style: const TextStyle(color: AppColors.primaryButton),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}