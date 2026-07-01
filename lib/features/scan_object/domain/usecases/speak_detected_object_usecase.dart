import '../../../../core/services/tts_services.dart';

class SpeakDetectedObjectUseCase {
  final TtsService _ttsService;

  SpeakDetectedObjectUseCase(this._ttsService);

  Future<void> call(String objectName) async {
    await _ttsService.speak(objectName);
  }
}
