import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/providers.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/services/tts_services.dart';
import '../../../history/domain/entities/history_item_entity.dart';
import '../../../history/domain/usecases/save_history_item_usecase.dart';
import '../../domain/usecases/read_text_from_image_usecase.dart';
import '../../domain/usecases/speak_text_usecase.dart';

final readTextControllerProvider = ChangeNotifierProvider.autoDispose<ReadTextController>((ref) {
  final readTextFromImage = ref.read(readTextFromImageUseCaseProvider);
  final speakText = ref.read(speakTextUseCaseProvider);
  final ttsService = ref.read(ttsServiceProvider);
  final saveHistoryItem = ref.read(saveHistoryItemUseCaseProvider);
  return ReadTextController(
    readTextFromImageUseCase: readTextFromImage,
    speakTextUseCase: speakText,
    ttsService: ttsService,
    saveHistoryItemUseCase: saveHistoryItem,
  );
});

class ReadTextController extends ChangeNotifier {
  final ReadTextFromImageUseCase _readTextFromImageUseCase;
  final SpeakTextUseCase _speakTextUseCase;
  final TtsService _ttsService;
  final SaveHistoryItemUseCase _saveHistoryItemUseCase;
  late final CameraService cameraService;

  bool _isProcessing = false;
  String? _resultText;
  String? _errorMessage;
  bool _isPlayingTts = false;

  ReadTextController({
    required ReadTextFromImageUseCase readTextFromImageUseCase,
    required SpeakTextUseCase speakTextUseCase,
    required TtsService ttsService,
    required SaveHistoryItemUseCase saveHistoryItemUseCase,
  })  : _readTextFromImageUseCase = readTextFromImageUseCase,
        _speakTextUseCase = speakTextUseCase,
        _ttsService = ttsService,
        _saveHistoryItemUseCase = saveHistoryItemUseCase {
    cameraService = CameraService(initialDirection: CameraLensDirection.back);
    cameraService.addListener(_onCameraStateChanged);
  }

  bool get isProcessing => _isProcessing;
  String? get resultText => _resultText;
  String? get errorMessage => _errorMessage;
  bool get isCameraInitialized => cameraService.isInitialized;
  bool get isPlayingTts => _isPlayingTts;

  void _onCameraStateChanged() {
    notifyListeners();
  }

  Future<void> initializeCamera() async {
    await cameraService.initialize();
  }

  Future<void> captureAndRecognize() async {
    if (_isProcessing) return;

    _isProcessing = true;
    _resultText = null;
    _errorMessage = null;
    _isPlayingTts = false;
    notifyListeners();

    try {
      final imageFile = await cameraService.captureImage();
      if (imageFile == null) {
        _errorMessage = 'Failed to capture image.';
        _isProcessing = false;
        notifyListeners();
        await _speakTextUseCase('فشل التقاط الصورة');
        return;
      }

      final file = File(imageFile.path);
      final result = await _readTextFromImageUseCase(file);
      _resultText = result;
      
      _isPlayingTts = true;
      notifyListeners();

      // Save to History!
      if (result.trim().isNotEmpty) {
        final lines = result.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
        final title = lines.isNotEmpty ? lines.first : 'Text Scan';
        final historyItem = HistoryItemEntity(
          id: const Uuid().v4(),
          type: 'text',
          title: title.length > 30 ? '${title.substring(0, 30)}...' : title,
          description: result,
          timestamp: DateTime.now(),
        );
        await _saveHistoryItemUseCase(historyItem);
      }

      // Speak the detected text
      await _speakTextUseCase(result);
    } catch (e) {
      _errorMessage = 'Error: $e';
      await _speakTextUseCase('حدث خطأ أثناء قراءة النص');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> repeatSpeech() async {
    if (_resultText == null || _resultText!.isEmpty) return;
    _isPlayingTts = true;
    notifyListeners();
    await _speakTextUseCase(_resultText!);
  }

  Future<void> stopSpeech() async {
    await _ttsService.stop();
    _isPlayingTts = false;
    notifyListeners();
  }

  Future<void> toggleCamera() async {
    await cameraService.switchCamera();
  }

  @override
  void dispose() {
    _ttsService.stop();
    cameraService.removeListener(_onCameraStateChanged);
    cameraService.dispose();
    super.dispose();
  }
}
