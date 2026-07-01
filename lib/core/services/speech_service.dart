import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();

  Future<String?> listen({String localeId = 'en_US'}) async {
    final micPermission = await Permission.microphone.request();

    if (!micPermission.isGranted) {
      return null;
    }

    final completer = Completer<String?>();

    String recognizedText = '';

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (!completer.isCompleted) {
            completer.complete(recognizedText.trim());
          }
        }
      },
      onError: (error) {
        debugPrint("SpeechToText Error: ${error.errorMsg} - permanent: ${error.permanent}");
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
    );

    if (!available) {
      debugPrint("SpeechToText Error: Speech recognition is not available on this device.");
      throw Exception("Speech recognition not supported on this device.");
    }

    await _speech.listen(
      localeId: localeId,
      listenFor: const Duration(seconds: 6),
      pauseFor: const Duration(seconds: 2),
      onResult: (result) {
        recognizedText = result.recognizedWords;

        if (result.finalResult && !completer.isCompleted) {
          completer.complete(recognizedText.trim());
        }
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () async {
        await _speech.stop();
        return recognizedText.trim();
      },
    );
  }

  Future<void> stop() async {
    await _speech.stop();
  }
}