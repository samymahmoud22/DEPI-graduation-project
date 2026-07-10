import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/providers.dart';
import '../../../../core/services/camera_service.dart';
import '../../../history/domain/entities/history_item_entity.dart';
import '../../../history/domain/usecases/save_history_item_usecase.dart';
import '../../domain/usecases/detect_objects_usecase.dart';
import '../../domain/usecases/speak_detected_object_usecase.dart';

final scanObjectControllerProvider = ChangeNotifierProvider.autoDispose<ScanObjectController>((ref) {
  final detectObjects = ref.read(detectObjectsUseCaseProvider);
  final speakDetectedObject = ref.read(speakDetectedObjectUseCaseProvider);
  final saveHistoryItem = ref.read(saveHistoryItemUseCaseProvider);
  return ScanObjectController(
    detectObjectsUseCase: detectObjects,
    speakDetectedObjectUseCase: speakDetectedObject,
    saveHistoryItemUseCase: saveHistoryItem,
  );
});

class ScanObjectController extends ChangeNotifier {
  final DetectObjectsUseCase _detectObjectsUseCase;
  final SpeakDetectedObjectUseCase _speakDetectedObjectUseCase;
  final SaveHistoryItemUseCase _saveHistoryItemUseCase;
  late final CameraService cameraService;

  bool _isProcessing = false;
  String? _resultText;
  String? _errorMessage;

  ScanObjectController({
    required DetectObjectsUseCase detectObjectsUseCase,
    required SpeakDetectedObjectUseCase speakDetectedObjectUseCase,
    required SaveHistoryItemUseCase saveHistoryItemUseCase,
  })  : _detectObjectsUseCase = detectObjectsUseCase,
        _speakDetectedObjectUseCase = speakDetectedObjectUseCase,
        _saveHistoryItemUseCase = saveHistoryItemUseCase {
    cameraService = CameraService(initialDirection: CameraLensDirection.back);
    cameraService.addListener(_onCameraStateChanged);
  }

  bool get isProcessing => _isProcessing;
  String? get resultText => _resultText;
  String? get errorMessage => _errorMessage;
  bool get isCameraInitialized => cameraService.isInitialized;

  void _onCameraStateChanged() {
    notifyListeners();
  }

  Future<void> initializeCamera() async {
    await cameraService.initialize();
  }

  Future<void> captureAndDetect() async {
    if (_isProcessing) return;

    _isProcessing = true;
    _resultText = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final imageFile = await cameraService.captureImage();
      if (imageFile == null) {
        _errorMessage = 'Failed to capture image.';
        _isProcessing = false;
        notifyListeners();
        await _speakDetectedObjectUseCase('فشل التقاط الصورة');
        return;
      }

      final file = File(imageFile.path);
      final result = await _detectObjectsUseCase(file);
      _resultText = result;

      // Save to History!
      if (result.trim().isNotEmpty) {
        final historyItem = HistoryItemEntity(
          id: const Uuid().v4(),
          type: 'object',
          title: result,
          description: result,
          timestamp: DateTime.now(),
        );
        await _saveHistoryItemUseCase(historyItem);
      }

      // Speak the detected object
      await _speakDetectedObjectUseCase(result);
    } catch (e) {
      _errorMessage = 'Error: $e';
      await _speakDetectedObjectUseCase('حدث خطأ أثناء التعرف على الأشياء');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> toggleCamera() async {
    await cameraService.switchCamera();
  }

  @override
  void dispose() {
    cameraService.removeListener(_onCameraStateChanged);
    cameraService.dispose();
    super.dispose();
  }
}
