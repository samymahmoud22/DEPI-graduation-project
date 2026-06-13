import 'package:flutter/material.dart';

import 'app/theme/app_theme.dart';
import 'features/home/presentation/views/voice_view.dart';
import 'features/splash/presentation/views/splash_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VisionMate());
}

class VisionMate extends StatelessWidget {
  const VisionMate({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vision Mate',
      theme: AppTheme.lightTheme,
      home: const SplashView(),
      routes: {
        '/voiceView': (context) => const VoiceView(),
      },
    );
  }
}
