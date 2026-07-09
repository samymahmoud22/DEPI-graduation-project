import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import 'package:visionmate/features/voice_assistant/domain/presentation/controller/voice_assistant_controller.dart';
import '../../../../core/localization/locale_provider.dart';
import '../widgets/greeting_section.dart';
import '../widgets/home_action_card.dart';
import '../widgets/voice_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  StreamSubscription? _accelerometerSubscription;
  static const double shakeThreshold = 15.0; 
  DateTime? _lastShakeTime;

  @override
  void initState() {
    super.initState();

    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      
      double speed = event.x * event.x + event.y * event.y + event.z * event.z;
      
      if (speed > shakeThreshold * shakeThreshold) {
        final now = DateTime.now();
        if (_lastShakeTime == null || now.difference(_lastShakeTime!) > const Duration(seconds: 2)) {
          _lastShakeTime = now;

          HapticFeedback.vibrate();

      
          if (mounted) {
            ref.read(voiceAssistantControllerProvider).handleVolumeUpTrigger(context);
          }
        }
      }
    });
  }

  @override
  void dispose() {
  
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceController = ref.watch(voiceAssistantControllerProvider);
    final isListening = voiceController.isListening;
    final t = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GreetingSection(),
              const SizedBox(height: 34),
              Center(
                child: VoiceButton(
                  onTap: () => voiceController.handleVolumeUpTrigger(context),
                  onLongPress: () => voiceController.handleVolumeUpTrigger(context),
                  isListening: isListening,
                ),
              ),
              const SizedBox(height: 50),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 14,
                childAspectRatio: 1.55,
                children: [
                  HomeActionCard(
                    title: t.get('scan_object'),
                    icon: Icons.camera_alt_outlined,
                    onTap: () => context.push(AppRoutes.scanObject),
                  ),
                  HomeActionCard(
                    title: t.get('read_text'),
                    icon: Icons.article_outlined,
                    onTap: () => context.push(AppRoutes.readText),
                  ),
                  HomeActionCard(
                    title: t.get('person'),
                    icon: Icons.person_outline,
                    onTap: () => context.push(AppRoutes.person),
                  ),
                  HomeActionCard(
                    title: t.get('location'),
                    icon: Icons.location_on_outlined,
                    onTap: () => context.push(AppRoutes.navigation),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
