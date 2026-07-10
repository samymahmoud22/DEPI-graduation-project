import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:visionmate/app/router.dart';
import 'package:visionmate/app/providers.dart';
import 'package:visionmate/core/localization/locale_provider.dart';
import 'package:visionmate/core/services/command_router_service.dart';
import 'package:visionmate/core/services/speech_service.dart';
import 'package:visionmate/core/services/tts_services.dart';

final voiceAssistantControllerProvider = ChangeNotifierProvider<VoiceAssistantController>((ref) {
  return VoiceAssistantController(ref);
});

/// Orchestrates the full voice-command flow triggered by the
/// global Volume Up long-press or the microphone button:
///
/// 1. Haptic vibration + system click  →  notify blind user
/// 2. Start `SpeechService.listen()`   →  capture Arabic/English speech
/// 3. Route via `CommandRouterService`  →  navigate to target screen
/// 4. TTS confirmation                 →  tell the user what happened
class VoiceAssistantController extends ChangeNotifier {
  final Ref _ref;
  final CommandRouterService _commandRouter = CommandRouterService();

  bool _isListening = false;
  bool get isListening => _isListening;

  String _lastText = '';
  String get lastText => _lastText;

  VoiceAssistantController(this._ref);

  SpeechService get _speechService => _ref.read(speechServiceProvider);
  TtsService get _ttsService => _ref.read(ttsServiceProvider);

  /// Entry-point called when a voice trigger is requested.
  Future<void> handleVolumeUpTrigger(BuildContext context) async {
    // Prevent overlapping triggers.
    if (_isListening) return;

    _isListening = true;
    _lastText = '';
    notifyListeners();

    final currentLocale = _ref.read(localeProvider);
    final t = _ref.read(translationsProvider);
    final langCode = currentLocale.languageCode;
    final speechLocale = langCode == 'ar' ? 'ar_SA' : 'en_US';

    try {
      // ── 1. Haptic + audio feedback ──────────────────────────────────────
      await _notifyUser();

      // ── 2. Listen for speech ─────────────────────────────────────
      final command = await _speechService.listen(localeId: speechLocale);
      _lastText = command ?? '';
      notifyListeners();

      if (!context.mounted) return;

      if (command == null || command.trim().isEmpty) {
        await _ttsService.speak(t.get('did_not_hear'), languageCode: langCode);
        return;
      }

      // ── 3. Resolve route from the transcribed command ───────────────────
      final route = _commandRouter.resolveRoute(command);

      if (route == 'back') {
        await _ttsService.speak(t.get('going_back'), languageCode: langCode);
        if (!context.mounted) return;
        if (GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
        } else {
          await _ttsService.speak(t.get('cannot_go_back'), languageCode: langCode);
        }
        return;
      }

      if (route == AppRoutes.home) {
        // Command was not recognized — tell the user.
        await _ttsService.speak(t.get('did_not_understand'), languageCode: langCode);
        return;
      }

      // ── 4. Navigate + confirm via TTS ───────────────────────────────────
      await _ttsService.speak(t.get('opening'), languageCode: langCode);

      if (!context.mounted) return;
      GoRouter.of(context).push(route);
    } catch (e) {
      debugPrint("Voice Assistant Error: $e");
      if (e.toString().contains("not supported")) {
        await _ttsService.speak(t.get('voice_assistant_unsupported'), languageCode: langCode);
      } else {
        await _ttsService.speak(t.get('voice_assistant_error'), languageCode: langCode);
      }
    } finally {
      _isListening = false;
      notifyListeners();
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Short vibration buzz + system click sound to let the user know
  /// the long-press was registered.
  Future<void> _notifyUser() async {
    // Vibrate for 200 ms (falls back gracefully if no vibrator).
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 200);
    }

    // Play a short system click sound.
    await SystemSound.play(SystemSoundType.click);
  }

  @override
  void dispose() {
    _speechService.stop();
    _ttsService.stop();
    super.dispose();
  }
}
