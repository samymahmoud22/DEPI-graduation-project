import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text, {String? languageCode}) async {
    if (languageCode != null) {
      await _tts.setLanguage(languageCode);
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) {
      await _tts.setLanguage('ar');
    } else {
      await _tts.setLanguage('en-US');
    }
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}