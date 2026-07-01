import '../../../../core/services/tts_services.dart';

class SpeakPersonNameUseCase {
  final TtsService _ttsService;

  SpeakPersonNameUseCase(this._ttsService);

  Future<void> call(String resultText) async {
    String cleanText = resultText;
    if (resultText.startsWith('MATCHED:')) {
      // Extract everything after the name in the matched response, or clean the tag
      cleanText = resultText.replaceFirst('MATCHED:', '').trim();
    } else if (resultText.startsWith('UNKNOWN:')) {
      cleanText = resultText.replaceFirst('UNKNOWN:', '').trim();
    }
    await _ttsService.speak(cleanText);
  }
}
