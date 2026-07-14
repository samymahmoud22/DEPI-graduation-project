import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  /// Initialize once and reuse across calls.
  Future<bool> _ensureInitialized() async {
    if (_isInitialized) return true;

    _isInitialized = await _speech.initialize(
      onError: (error) {
        debugPrint("SpeechToText Error: ${error.errorMsg} - permanent: ${error.permanent}");
      },
    );

    if (!_isInitialized) {
      debugPrint("SpeechToText Error: Speech recognition is not available on this device.");
    }
    return _isInitialized;
  }

  Future<String?> listen({String localeId = 'en_US'}) async {
    final micPermission = await Permission.microphone.request();

    if (!micPermission.isGranted) {
      debugPrint("SpeechService: Microphone permission denied.");
      return null;
    }

    final available = await _ensureInitialized();

    if (!available) {
      throw Exception("Speech recognition not supported on this device.");
    }

    // Stop any previous session before starting a new one.
    if (_speech.isListening) {
      await _speech.stop();
    }

    final completer = Completer<String?>();
    String recognizedText = '';

    await _speech.listen(
      localeId: localeId,
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: false,
      listenMode: ListenMode.dictation,
      onResult: (result) {
        recognizedText = result.recognizedWords;
        debugPrint("SpeechService onResult: '$recognizedText' (final: ${result.finalResult})");

        if (result.finalResult && !completer.isCompleted) {
          completer.complete(recognizedText.trim());
        }
      },
      onSoundLevelChange: (level) {
        // Optional: can be used for UI feedback
      },
    );

    // Listen for status changes to detect when listening stops
    // without getting a final result.
    _speech.statusListener = (status) {
      debugPrint("SpeechService status: $status");
      if ((status == 'done' || status == 'notListening') && !completer.isCompleted) {
        // Small delay to allow any pending onResult to fire first.
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!completer.isCompleted) {
            completer.complete(recognizedText.trim().isEmpty ? null : recognizedText.trim());
          }
        });
      }
    };

    return completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () async {
        debugPrint("SpeechService: Timeout reached. Stopping.");
        await _speech.stop();
        return recognizedText.trim().isEmpty ? null : recognizedText.trim();
      },
    );
  }

  Future<void> stop() async {
    await _speech.stop();
  }
}