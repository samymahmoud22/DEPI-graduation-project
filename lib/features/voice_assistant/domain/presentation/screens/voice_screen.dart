import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:visionmate/app/theme/app_colors.dart';
import 'package:visionmate/core/widgets/bottom_nav_bar.dart';
import 'package:visionmate/core/localization/locale_provider.dart';
import 'package:visionmate/app/providers.dart';
import 'package:visionmate/features/voice_assistant/domain/presentation/controller/voice_assistant_controller.dart';

class VoiceScreen extends ConsumerWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceController = ref.watch(voiceAssistantControllerProvider);
    final isListening = voiceController.isListening;
    final t = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.white),
              ),
              const SizedBox(height: 10),

              Center(
                child: GestureDetector(
                  onTap: () => voiceController.handleVolumeUpTrigger(context),
                  child: Container(
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening ? AppColors.green.withValues(alpha: 0.2) : const Color(0xFF214D80),
                    ),
                    child: Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isListening ? AppColors.green : AppColors.micCircle,
                        ),
                        child: Icon(
                          isListening ? Icons.hearing_rounded : Icons.mic_none_rounded,
                          color: AppColors.white,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Center(
                child: SizedBox(
                  width: 140,
                  height: 34,
                  child: ElevatedButton(
                    onPressed: isListening ? null : () => voiceController.handleVolumeUpTrigger(context),
                    child: Text(isListening ? t.get('listening') : t.get('tap_to_speak')),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                height: 130,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.fieldBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get('what_i_found'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          voiceController.lastText,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        onPressed: () {
                          // Stop action
                          ref.read(speechServiceProvider).stop();
                          ref.read(ttsServiceProvider).stop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                        ),
                        child: Text(t.get('stop')),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        onPressed: () => voiceController.handleVolumeUpTrigger(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                        ),
                        child: Text(t.get('repeat')),
                      ),
                    ),
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