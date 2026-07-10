import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // Brand Colors
  static const Color _primaryBlue = Color(0xFF005088);
  static const Color _accentTeal = Color(0xFF11CAA0);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(resetPasswordUseCaseProvider)(_emailController.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
            style: TextStyle(fontFamily: 'Cairo'),
            textAlign: TextAlign.right,
          ),
          backgroundColor: AppColors.green,
        ),
      );

      // Go back to login screen after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.pop();
        }
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ: ${e.toString()}',
            style: const TextStyle(fontFamily: 'Cairo'),
            textAlign: TextAlign.right,
          ),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Icon
                SvgPicture.asset(
                  'lib/logo.svg',
                  height: 100,
                  width: 100,
                  colorFilter: const ColorFilter.mode(
                    _accentTeal,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Clean modern Card
                Card(
                  color: AppColors.card,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'نسيت كلمة المرور؟',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'أدخل بريدك الإلكتروني لإرسال رابط إعادة تعيين كلمة المرور الخاصة بك.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              color: AppColors.white70,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Email field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.black),
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'البريد الإلكتروني',
                              hintStyle: const TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.grey,
                              ),
                              fillColor: AppColors.fieldBackground,
                              filled: true,
                              prefixIcon: const Icon(Icons.email_outlined, color: _primaryBlue),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: _accentTeal,
                                  width: 2,
                                ),
                              ),
                              errorStyle: const TextStyle(
                                fontFamily: 'Cairo',
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الرجاء إدخال البريد الإلكتروني';
                              }
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'الرجاء إدخال بريد إلكتروني صحيح';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Submit Button with async loading
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_primaryBlue, _accentTeal],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : const Text(
                                      'إرسال رابط إعادة التعيين',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Back to Login button
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'العودة لتسجيل الدخول',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: _accentTeal,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
