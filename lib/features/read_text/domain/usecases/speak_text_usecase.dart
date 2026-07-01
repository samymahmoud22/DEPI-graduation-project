import '../../../../core/services/tts_services.dart';

class SpeakTextUseCase {
  final TtsService _ttsService;

  SpeakTextUseCase(this._ttsService);

  Future<void> call(String text) async {
    await _ttsService.speak(text);
  }
}
