import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/result_box.dart';
import '../controller/read_text_controller.dart';

class ReadTextScreen extends ConsumerStatefulWidget {
  const ReadTextScreen({super.key});

  @override
  ConsumerState<ReadTextScreen> createState() => _ReadTextScreenState();
}

class _ReadTextScreenState extends ConsumerState<ReadTextScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(readTextControllerProvider).initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ReadTextController>(readTextControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.red,
          ),
        );
      }
    });

    final state = ref.watch(readTextControllerProvider);
    final controller = state.cameraService.controller;
    final isInitialized = state.isCameraInitialized;
    final errorMessage = state.cameraService.errorMessage ?? state.errorMessage;
    final isProcessing = state.isProcessing;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Read Text',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenTitle,
                    ),
                  ),
                  const SizedBox(width: 48), // Balancing back button
                ],
              ),
              const SizedBox(height: 18),

              // Camera Viewport
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.bottomNav,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryButton.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isInitialized && controller != null)
                        Positioned.fill(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: controller.value.previewSize?.height ?? 1080,
                              height: controller.value.previewSize?.width ?? 1920,
                              child: CameraPreview(controller),
                            ),
                          ),
                        )
                      else if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.red, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                errorMessage,
                                style: AppTextStyles.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref.read(readTextControllerProvider).initializeCamera(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      else
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.primaryButton),
                            SizedBox(height: 16),
                            Text(
                              'Initializing Camera...',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),

                      // Camera switch overlay button
                      if (isInitialized)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withValues(alpha: 0.5),
                            child: IconButton(
                              icon: const Icon(
                                Icons.flip_camera_ios_outlined,
                                color: AppColors.white,
                              ),
                              onPressed: () => ref.read(readTextControllerProvider).toggleCamera(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Recognized Text Box
              ResultBox(
                height: 120,
                text: state.resultText ?? 'Recognized text will appear here...',
              ),

              const SizedBox(height: 18),

              // Action button
              PrimaryButton(
                text: isProcessing ? 'Processing...' : 'Capture',
                onPressed: (isInitialized && !isProcessing)
                    ? () => ref.read(readTextControllerProvider).captureAndRecognize()
                    : null,
              ),

              const SizedBox(height: 18),

              // Stop & Repeat controls
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Stop',
                      color: AppColors.red,
                      onPressed: state.isPlayingTts
                          ? () => ref.read(readTextControllerProvider).stopSpeech()
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Repeat',
                      color: AppColors.green,
                      onPressed: (state.resultText != null && state.resultText!.isNotEmpty)
                          ? () => ref.read(readTextControllerProvider).repeatSpeech()
                          : null,
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