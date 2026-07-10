import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/providers.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../history/domain/entities/history_item_entity.dart';
import '../widgets/face_frame_overlay.dart';

class PersonScreen extends ConsumerStatefulWidget {
  const PersonScreen({super.key});

  @override
  ConsumerState<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends ConsumerState<PersonScreen> {
  late final CameraService _cameraService;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    // Default to the front camera for face recognition
    _cameraService = CameraService(initialDirection: CameraLensDirection.front);
    _cameraService.addListener(_onCameraStateChanged);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initialize();
  }

  void _onCameraStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraService.removeListener(_onCameraStateChanged);
    _cameraService.dispose();
    super.dispose();
  }

  Future<void> _captureAndProcess() async {
    if (_isCapturing) return;
    final t = ref.read(translationsProvider);

    setState(() {
      _isCapturing = true;
    });

    try {
      final image = await _cameraService.captureImage();
      if (image != null) {
        final imageFile = File(image.path);

        // Perform face verification/detection check
        final faceDetected = await ref.read(detectFaceUseCaseProvider)(imageFile);
        if (!faceDetected) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(t.get('no_face_detected')),
                backgroundColor: AppColors.red,
              ),
            );
          }
          return;
        }

        // Call matchPersonUseCase
        final recognitionResult = await ref.read(matchPersonUseCaseProvider)(imageFile);

        // Speak the recognized person's details
        await ref.read(speakPersonNameUseCaseProvider)(recognitionResult);

        // Save to History!
        try {
          final bool isMatched = recognitionResult.startsWith('MATCHED:');
          final cleanDesc = recognitionResult
              .replaceFirst('MATCHED:', '')
              .replaceFirst('UNKNOWN:', '')
              .trim();

          final historyItem = HistoryItemEntity(
            id: const Uuid().v4(),
            type: 'person',
            title: isMatched ? t.get('person_recognized_history') : t.get('unknown_person_history'),
            description: cleanDesc,
            timestamp: DateTime.now(),
          );
          await ref.read(saveHistoryItemUseCaseProvider)(historyItem);
        } catch (e) {
          debugPrint('Error saving face capture history: $e');
        }

        if (mounted) {
          _showResultBottomSheet(recognitionResult);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.get('capture_failed')),
              backgroundColor: AppColors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final t = ref.read(translationsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.get('recognition_error', [e.toString()])),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _showResultBottomSheet(String resultText) {
    final t = ref.read(translationsProvider);
    final bool isMatched = resultText.startsWith('MATCHED:');
    final cleanText = resultText
        .replaceFirst('MATCHED:', '')
        .replaceFirst('UNKNOWN:', '')
        .trim();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bottomNav,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    isMatched ? Icons.check_circle : Icons.help_outline,
                    color: isMatched ? AppColors.green : AppColors.placeholder,
                    size: 36,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    isMatched ? t.get('person_recognized') : t.get('unknown_person'),
                    style: AppTextStyles.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                cleanText,
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(t.get('close'), style: AppTextStyles.button),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleCamera() async {
    await _cameraService.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraService.controller;
    final isInitialized = _cameraService.isInitialized;
    final errorMessage = _cameraService.errorMessage;
    final t = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              // Header Row
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  ),
                  Expanded(
                    child: Text(
                      t.get('face_recognition'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenTitle,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push(AppRoutes.enrollPerson),
                    icon: const Icon(Icons.person_add_alt_1, color: AppColors.white),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Camera frame
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 400),
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
                                    onPressed: _initializeCamera,
                                    child: Text(t.get('retry')),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(color: AppColors.primaryButton),
                                const SizedBox(height: 16),
                                Text(
                                  t.get('initializing_camera'),
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),

                          // Face frame guide overlay (only when camera is ready)
                          if (isInitialized && controller != null)
                            const Positioned.fill(child: FaceFrameOverlay()),

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
                                  onPressed: _toggleCamera,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.center,
                child: Text(
                  t.get('align_face'),
                  style: AppTextStyles.bodyLarge,
                ),
              ),

              const SizedBox(height: 24),

              // Capture Action Button
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  onPressed: (isInitialized && !_isCapturing) ? _captureAndProcess : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.placeholder,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isCapturing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt, color: AppColors.white),
                            const SizedBox(width: 8),
                            Text(
                              t.get('capture'),
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