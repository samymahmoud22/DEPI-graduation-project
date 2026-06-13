import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/assets.dart';
import '../../../auth/presentation/views/login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _letters = ['L', 'o', 'a', 'd', 'i', 'n', 'g', '...'];
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
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
            parent: _controller,
            curve: Interval(start, end),
          ),
        ),
      );
    }

    _controller.repeat(reverse: false);

    // Navigate to LoginView after 3 seconds.
    // The animation completes at ~2.35s, giving a tiny pause before navigation.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Semantics(
        label: 'Vision Mate application, loading. Splash screen active.',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              
              // Logo
              Image.asset(
                AssetsData.logo,
                height: 160,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 160,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              
              // App Name
              const Text(
                'Vision Mate',
                style: AppTextStyles.font40Bold,
              ),
              const SizedBox(height: 10),
              
              // Tagline
              const Text(
                'AI Assistant for Visual Accessibility',
                style: AppTextStyles.font20Regular,
                textAlign: TextAlign.center,
              ),
              
              const Spacer(flex: 2),
              
              // Sequential Animated Loading Indicator
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_letters.length, (index) {
                      return Transform.translate(
                        // Translate handles the sliding from 300px offset to 0
                        offset: Offset(_animations[index].value, 0),
                        child: Text(
                          _letters[index],
                          style: AppTextStyles.font20Regular,
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
    );
  }
}
