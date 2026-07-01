import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/locale_provider.dart';
import '../controller/login_controller.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final controller = ref.read(loginControllerProvider);
    final t = ref.read(translationsProvider);

    final result = await controller.login(
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted) return;

    if (result == LoginResult.success) {
      context.go(AppRoutes.home);
    } else if (result == LoginResult.emailNotVerified) {
      context.push(
        '${AppRoutes.emailVerification}?email=${Uri.encodeComponent(emailController.text.trim())}',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? t.get('login_failed')),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  void _goToSignup() => context.push(AppRoutes.signup);

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(loginControllerProvider);
    final t = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const SizedBox(height: 18),
              AuthHeader(title: t.get('login')),
              const Spacer(flex: 2),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(hintText: t.get('email')),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.black),
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
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 4),
                    minimumSize: const Size(0, 30),
                  ),
                  child: Text(
                    t.get('forgot_password'),
                    style: const TextStyle(color: AppColors.white70, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: controller.isLoading ? null : _login,
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(t.get('login')),
                ),
              ),
              const Spacer(flex: 4),
              Text(
                t.get('no_account'),
                style: AppTextStyles.bodyLarge,
              ),
              TextButton(
                onPressed: _goToSignup,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 26),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  t.get('signup'),
                  style: const TextStyle(color: AppColors.primaryButton),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}