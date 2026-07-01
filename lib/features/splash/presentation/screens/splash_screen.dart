import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../controller/splash_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  final SplashController _controller = SplashController();
  late AnimationController _animationController;
  final List<String> _letters = ['L', 'o', 'a', 'd', 'i', 'n', 'g', '...'];
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _animations = [];

    for (int i = 0; i < _letters.length; i++) {
      // 0.12 multiplier creates a 0.02 gap between letters
      // (e.g., L ends at 0.10, o starts at 0.12)
      final double start = i * 0.12; 
      final double end = start + 0.10; 

      _animations.add(
        TweenSequence<double>([
          // The sliding part (starts smooth and ends smooth)
          TweenSequenceItem(
            tween: Tween<double>(begin: 300.0, end: -5.0)
                .chain(CurveTween(curve: Curves.easeInOut)),
            weight: 70, // 70% of the interval time
          ),
          // The collision bounce at the very end
          TweenSequenceItem(
            tween: Tween<double>(begin: -5.0, end: 0.0)
                .chain(CurveTween(curve: Curves.bounceOut)),
            weight: 30, // 30% of the interval time
          ),
        ]).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(start, end),
          ),
        ),
      );
    }

    _animationController.repeat(reverse: false);

    Future.microtask(() async {
      final user = ref.read(getCurrentUserUseCaseProvider)();
      if (!mounted) return;

      bool isLoggedIn = false;
      if (user != null) {
        try {
          await user.reload();
          final refreshedUser = FirebaseAuth.instance.currentUser;
          isLoggedIn = refreshedUser != null && refreshedUser.emailVerified;
        } catch (e) {
          isLoggedIn = false;
        }
      }

      if (!mounted) return;
      _controller.navigate(context: context, isLoggedIn: isLoggedIn);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Semantics(
          label: 'Vision Mate application, loading. Splash screen active.',
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  
                  // Logo
                  SvgPicture.asset(
                    'lib/logo.svg',
                    height: 160,
                    width: 160,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // App Name
                  const Text(
                    'Vision Mate',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Tagline
                  const Text(
                    'AI Assistant for Visual Accessibility',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Sequential Animated Loading Indicator
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_letters.length, (index) {
                          return Transform.translate(
                            // Translate handles the sliding from 300px offset to 0
                            offset: Offset(_animations[index].value, 0),
                            child: Text(
                              _letters[index],
                              style: const TextStyle(
                                fontSize: 20,
                                color: AppColors.white,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
