import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:vibration/vibration.dart';
import 'package:camera/camera.dart';

import '../../../../core/services/speech_service.dart';
import '../../../../core/services/tts_services.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/providers/safe_walk_provider.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../app/providers.dart';
import '../../../history/domain/entities/history_item_entity.dart';
import '../../data/datasources/geocoding_datasource.dart';
import '../../data/datasources/geolocation_datasource.dart';
import '../../data/datasources/routes_datasource.dart';
import '../../data/models/destination_model.dart';
import '../../data/models/navigation_session_model.dart';

/// Riverpod provider — gives every screen access to the same instance.
final navigationControllerProvider =
    ChangeNotifierProvider<NavigationController>((ref) {
  return NavigationController(ref);
});

/// Manages the full voice-interactive navigation flow:
///
/// 1. Voice input → capture destination name
/// 2. Geocode → get coordinates
/// 3. Directions API → get turn-by-turn route
/// 4. GPS tracking → announce steps as user walks
class NavigationController extends ChangeNotifier {
  final Ref _ref;

  // ── Data sources ────────────────────────────────────────────────────
  final GeolocationDatasource _geolocation = GeolocationDatasource();
  final GeocodingDatasource _geocoding = GeocodingDatasource();
  final RoutesDatasource _routes = RoutesDatasource();

  // ── Services ────────────────────────────────────────────────────────
  SpeechService get _speechService => _ref.read(speechServiceProvider);
  TtsService get _ttsService => _ref.read(ttsServiceProvider);

  // ── State ───────────────────────────────────────────────────────────
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  String _currentAddress = '';
  String get currentAddress => _currentAddress;

  DestinationModel? _destination;
  DestinationModel? get destination => _destination;

  NavigationSessionModel? _session;
  NavigationSessionModel? get session => _session;

  int _currentStepIndex = 0;
  int get currentStepIndex => _currentStepIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isListeningForDestination = false;
  bool get isListeningForDestination => _isListeningForDestination;

  bool _isNavigating = false;
  bool get isNavigating => _isNavigating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<Position>? _positionSub;

  // ── Safe Walk State ──────────────────────────────────────────────────
  Timer? _safeWalkTimer;
  CameraService? _safeWalkCameraService;
  bool _isCheckingSafeWalk = false;
  DateTime? _lastAlertTime;
  static const Duration _alertCooldown = Duration(seconds: 30);

  bool get isSafeWalkEnabled => _ref.read(safeWalkProvider);

  // ── Constructor ─────────────────────────────────────────────────────
  NavigationController(this._ref);

  // ── Convenience getters ─────────────────────────────────────────────

  /// The current route step (if navigating).
  get currentStep =>
      (_session != null && _currentStepIndex < _session!.steps.length)
          ? _session!.steps[_currentStepIndex]
          : null;

  /// True when we have a route but haven't started navigating yet.
  bool get hasRoute => _session != null && !_isNavigating;

  // ══════════════════════════════════════════════════════════════════════
  // PUBLIC ACTIONS
  // ══════════════════════════════════════════════════════════════════════

  /// Fetches the device's current GPS position + reverse-geocodes it.
  Future<void> fetchCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPosition = await _geolocation.getCurrentPosition();
      _currentAddress = await _geocoding.getAddressFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── 1. Voice Input ──────────────────────────────────────────────────

  /// Opens the microphone, captures the destination by voice,
  /// then geocodes + fetches the route.
  Future<void> startVoiceInput() async {
    if (_isListeningForDestination || _isLoading) return;

    _isListeningForDestination = true;
    notifyListeners();

    try {
      // Haptic + sound feedback.
      await _notifyUser();

      // Prompt the user.
      await _ttsService.speak('فين عايز تروح؟');

      // Wait a beat so TTS finishes before listening.
      await Future.delayed(const Duration(milliseconds: 1500));

      // Listen for Arabic speech.
      final spokenText = await _speechService.listen(localeId: 'ar_SA');

      if (spokenText == null || spokenText.trim().isEmpty) {
        await _ttsService.speak('لم أسمع شيئاً. اضغط تاني عشان تتكلم.');
        return;
      }

      // Search + route.
      await _searchAndRoute(spokenText.trim());
    } catch (e) {
      debugPrint('Voice input error: $e');
      await _ttsService.speak('حصل مشكلة في التعرف على الصوت');
    } finally {
      _isListeningForDestination = false;
      notifyListeners();
    }
  }

  // ── 2. Search & Route ───────────────────────────────────────────────

  /// Geocodes [query] and fetches turn-by-turn directions.
  Future<void> _searchAndRoute(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ttsService.speak('جاري البحث عن $query');

      // Geocode destination.
      final location = await _geocoding.getCoordinatesFromAddress(query);

      if (location == null) {
        _errorMessage = 'لم أجد "$query"';
        await _ttsService.speak('مش لاقي المكان ده. جرب تاني.');
        return;
      }

      _destination = DestinationModel(
        name: query,
        latitude: location.latitude,
        longitude: location.longitude,
      );
      notifyListeners();

      // Save to History!
      try {
        final historyItem = HistoryItemEntity(
          id: const Uuid().v4(),
          type: 'navigation',
          title: query,
          description: 'خط العرض: ${location.latitude.toStringAsFixed(4)}, خط الطول: ${location.longitude.toStringAsFixed(4)}',
          timestamp: DateTime.now(),
        );
        await _ref.read(saveHistoryItemUseCaseProvider)(historyItem);
      } catch (e) {
        debugPrint('Error saving search history: $e');
      }

      // Make sure we have current position.
      if (_currentPosition == null) {
        await fetchCurrentLocation();
      }

      if (_currentPosition == null) {
        await _ttsService.speak('مش قادر أحدد موقعك الحالي');
        return;
      }

      // Fetch route.
      final routeSession = await _routes.getRoute(
        originLat: _currentPosition!.latitude,
        originLng: _currentPosition!.longitude,
        destLat: location.latitude,
        destLng: location.longitude,
        destinationName: query,
      );

      if (routeSession == null || routeSession.steps.isEmpty) {
        _errorMessage = 'لم أجد طريق لـ "$query"';
        await _ttsService.speak('مش لاقي طريق للمكان ده');
        return;
      }

      _session = routeSession;
      _currentStepIndex = 0;
      notifyListeners();

      // Announce route summary.
      await _ttsService.speak(
        'تم العثور على الطريق إلى $query. '
        'المسافة ${routeSession.totalDistance}. '
        'الوقت ${routeSession.totalDuration}. '
        'اضغط عشان تبدأ التنقل.',
      );
    } catch (e) {
      _errorMessage = e.toString();
      await _ttsService.speak('حصل مشكلة أثناء البحث');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Public version of search for external callers (e.g. text field).
  Future<bool> searchDestination(String query) async {
    await _searchAndRoute(query);
    return _session != null;
  }

  // ── 3. Start / Stop Navigation ──────────────────────────────────────

  /// Begins live GPS tracking and announces the first step.
  Future<void> startNavigation() async {
    if (_session == null || _session!.steps.isEmpty) return;

    _isNavigating = true;
    _currentStepIndex = 0;
    notifyListeners();

    // Announce the first step.
    await _announceStep(_currentStepIndex);

    // Start listening to GPS.
    _positionSub = _geolocation.getPositionStream().listen(
      _onPositionUpdate,
      onError: (e) {
        debugPrint('GPS stream error: $e');
      },
    );

    // Start Safe Walk background detection if enabled
    if (isSafeWalkEnabled) {
      _startSafeWalkDetection();
    }
  }

  /// Stops navigation, cancels GPS subscription.
  Future<void> stopNavigation() async {
    await _positionSub?.cancel();
    _positionSub = null;
    _isNavigating = false;
    _stopSafeWalkDetection();
    notifyListeners();

    await _ttsService.speak('تم إيقاف التنقل');
  }

  /// Re-announces the current step (user can tap to re-hear).
  Future<void> announceCurrentStep() async {
    if (_session == null || !_isNavigating) return;
    await _announceStep(_currentStepIndex);
  }

  /// Clears all navigation state and goes back to initial screen.
  void resetNavigation() {
    _positionSub?.cancel();
    _positionSub = null;
    _session = null;
    _destination = null;
    _isNavigating = false;
    _currentStepIndex = 0;
    _errorMessage = null;
    _stopSafeWalkDetection();
    notifyListeners();
  }

  /// Toggles the Safe Walk feature on-the-fly.
  Future<void> toggleSafeWalk() async {
    final currentlyEnabled = isSafeWalkEnabled;
    await _ref.read(safeWalkProvider.notifier).setSafeWalk(!currentlyEnabled);
    notifyListeners();

    if (!currentlyEnabled) {
      if (_isNavigating) {
        _startSafeWalkDetection();
      }
    } else {
      _stopSafeWalkDetection();
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════════════

  /// Called on every GPS position update during navigation.
  void _onPositionUpdate(Position position) {
    _currentPosition = position;

    if (_session == null) return;

    final steps = _session!.steps;
    if (_currentStepIndex >= steps.length) return;

    final nextStep = steps[_currentStepIndex];

    // Distance (metres) from the user to the END of the current step.
    final distanceToStepEnd = _haversineMeters(
      position.latitude,
      position.longitude,
      nextStep.endLat,
      nextStep.endLng,
    );

    // When within 30 m of the step's end → advance to next step.
    if (distanceToStepEnd < 30) {
      _currentStepIndex++;
      notifyListeners();

      if (_currentStepIndex >= steps.length) {
        // Arrived!
        _ttsService.speak('وصلت! الوجهة قدامك.');
        stopNavigation();
        return;
      }

      _announceStep(_currentStepIndex);
    }
  }

  /// Speaks a specific step's instruction via TTS.
  Future<void> _announceStep(int index) async {
    if (_session == null || index >= _session!.steps.length) return;

    final step = _session!.steps[index];
    final stepNum = index + 1;
    final totalSteps = _session!.steps.length;

    // e.g. "الخطوة 2 من 5: خش يمين، 200 متر"
    final announcement =
        'الخطوة $stepNum من $totalSteps: ${step.spokenInstruction}';

    await _ttsService.speak(announcement);
  }

  /// Short vibration + click sound.
  Future<void> _notifyUser() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 200);
    }
    await SystemSound.play(SystemSoundType.click);
  }

  /// Haversine distance between two GPS points in metres.
  static double _haversineMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const R = 6371000.0; // Earth radius in metres
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _deg2rad(double deg) => deg * (pi / 180);

  void _startSafeWalkDetection() {
    _safeWalkTimer?.cancel();
    _safeWalkCameraService = CameraService(initialDirection: CameraLensDirection.back);

    _safeWalkCameraService!.initialize().then((_) {
      if (_isNavigating && _safeWalkCameraService!.isInitialized) {
        _safeWalkTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
          if (!_isNavigating) {
            timer.cancel();
            return;
          }
          await _checkSafeWalkFrame();
        });
      }
    }).catchError((e) {
      debugPrint('Safe Walk background camera initialization failed: $e');
    });
  }

  Future<void> _checkSafeWalkFrame() async {
    if (_isCheckingSafeWalk || _safeWalkCameraService == null || !_safeWalkCameraService!.isInitialized) return;

    // Cooldown: skip if we alerted recently
    if (_lastAlertTime != null &&
        DateTime.now().difference(_lastAlertTime!) < _alertCooldown) {
      return;
    }

    // Speed check: skip if the user is stationary (speed < 0.5 m/s)
    if (_currentPosition != null && (_currentPosition!.speed < 0.5)) {
      debugPrint('Safe Walk skipped: user is stationary (speed=${_currentPosition!.speed})');
      return;
    }

    _isCheckingSafeWalk = true;
    try {
      final imageFile = await _safeWalkCameraService!.captureImage();
      if (imageFile != null) {
        final file = File(imageFile.path);

        final geminiDataSource = _ref.read(geminiRemoteDataSourceProvider);
        const prompt = 'You are an obstacle detection system for a blind person who is WALKING outdoors. '
            'Analyze this image of their walking path. '
            'ONLY report DANGEROUS obstacles that pose an IMMEDIATE physical hazard within 1-2 meters directly on their walking path: '
            '- Deep holes, open manholes, or trenches they could fall into '
            '- Descending stairs or sudden drops '
            '- Large immovable barriers blocking the entire path (walls, construction barriers, vehicles parked across the sidewalk) '
            'Do NOT report: furniture, people standing nearby, items on tables, parked vehicles beside the path, '
            'walls on the side, trees, benches, or anything that is not directly blocking their forward walking path. '
            'Respond with ONLY one word in Arabic (no punctuation, no extra text): '
            '"حفرة" for holes/trenches, "درج" for stairs/drops, "عقبة" for blocking barriers, "لا" if path is clear/safe.';

        final result = await geminiDataSource.analyzeImageAndText(
          prompt: prompt,
          image: file,
        );

        final cleanResult = result.trim();
        debugPrint('Safe Walk detection result: $cleanResult');

        // Use contains() since Gemini may add extra text
        if (cleanResult.contains('حفرة')) {
          await _triggerHazardAlert('hole');
        } else if (cleanResult.contains('درج')) {
          await _triggerHazardAlert('stairs');
        } else if (cleanResult.contains('عقبة')) {
          await _triggerHazardAlert('obstacle');
        }

        // Clean up captured temp file
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Safe Walk frame scan failed: $e');
    } finally {
      _isCheckingSafeWalk = false;
    }
  }

  Future<void> _triggerHazardAlert(String obstacleType) async {
    _lastAlertTime = DateTime.now();

    // 1. Pulsing Vibration
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      await Vibration.vibrate(pattern: [0, 400, 100, 400, 100, 400]);
    }

    // 2. Beep/Alert sound
    await SystemSound.play(SystemSoundType.alert);

    // 3. TTS alert warning (localized)
    final t = _ref.read(translationsProvider);
    String warningMessage;
    switch (obstacleType) {
      case 'hole':
        warningMessage = t.get('warn_hole');
        break;
      case 'stairs':
        warningMessage = t.get('warn_stairs');
        break;
      default:
        warningMessage = t.get('warn_obstacle');
    }

    await _ttsService.speak(warningMessage);
  }

  void _stopSafeWalkDetection() {
    _safeWalkTimer?.cancel();
    _safeWalkTimer = null;
    _safeWalkCameraService?.dispose();
    _safeWalkCameraService = null;
  }

  // ── Dispose ─────────────────────────────────────────────────────────

  @override
  void dispose() {
    _positionSub?.cancel();
    _stopSafeWalkDetection();
    super.dispose();
  }
}
