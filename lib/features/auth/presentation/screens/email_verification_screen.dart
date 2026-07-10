import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/locale_provider.dart';
import '../widgets/auth_header.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isResending = false;

  Future<void> _resendVerification() async {
    setState(() => _isResending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      }
      if (mounted) {
        final t = ref.read(translationsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.get('email_resent')),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _goToLogin() {
    // Sign out so user must login with verified email
    FirebaseAuth.instance.signOut();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 18),
                AuthHeader(title: t.get('verify_email')),
                const Spacer(flex: 2),

                // Email icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryButton,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.primaryButton,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  t.get('verification_sent'),
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: const TextStyle(
                    color: AppColors.primaryButton,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  t.get('check_inbox'),
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  t.get('check_spam'),
                  style: const TextStyle(color: AppColors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Resend button
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton(
                    onPressed: _isResending ? null : _resendVerification,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryButton),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isResending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryButton,
                            ),
                          )
                        : Text(
                            t.get('resend_email'),
                            style: const TextStyle(color: AppColors.primaryButton),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Continue to Login
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _goToLogin,
                    child: Text(t.get('continue_to_login')),
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
