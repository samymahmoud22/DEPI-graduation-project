import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../controller/scan_object_controller.dart';

class ScanObjectScreen extends ConsumerStatefulWidget {
  const ScanObjectScreen({super.key});

  @override
  ConsumerState<ScanObjectScreen> createState() => _ScanObjectScreenState();
}

class _ScanObjectScreenState extends ConsumerState<ScanObjectScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(scanObjectControllerProvider).initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ScanObjectController>(scanObjectControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.red,
          ),
        );
      }
    });

    final state = ref.watch(scanObjectControllerProvider);
    final controller = state.cameraService.controller;
    final isInitialized = state.isCameraInitialized;
    final errorMessage = state.cameraService.errorMessage ?? state.errorMessage;
    final isProcessing = state.isProcessing;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: Padding(
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
                      'Scan Object',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenTitle,
                    ),
                  ),
                  const SizedBox(width: 48), // Balancing back button
                ],
              ),
              const SizedBox(height: 18),

              // Camera Viewport
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 380),
                    decoration: BoxDecoration(
                      color: AppColors.bottomNav,
                      borderRadius: BorderRadius.circular(24),
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
                      borderRadius: BorderRadius.circular(22),
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
                                    onPressed: () => ref.read(scanObjectControllerProvider).initializeCamera(),
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
                                  onPressed: () => ref.read(scanObjectControllerProvider).toggleCamera(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Detected Result
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Object detected:',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.resultText ?? 'Tap Capture to scan',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: (isInitialized && !isProcessing)
                      ? () => ref.read(scanObjectControllerProvider).captureAndDetect()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.placeholder,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt),
                            SizedBox(width: 8),
                            Text(
                              'Capture',
                              style: AppTextStyles.button,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}