import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';


class CameraService extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  CameraLensDirection _currentDirection;
  bool _isInitialized = false;
  String? _errorMessage;

  CameraService({
    CameraLensDirection initialDirection = CameraLensDirection.front,
  }) : _currentDirection = initialDirection;

 

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  CameraLensDirection get currentDirection => _currentDirection;

  
  Future<void> initialize() async {
    try {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        _errorMessage = 'Camera permission denied.';
        notifyListeners();
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _errorMessage = 'No cameras found on this device.';
        notifyListeners();
        return;
      }

      await _initCamera(_currentDirection);
    } catch (e) {
      _errorMessage = 'Camera error: $e';
      notifyListeners();
    }
  }

  Future<void> _initCamera(CameraLensDirection direction) async {
    
    if (_controller != null) {
      await _controller!.dispose();
      _isInitialized = false;
    }

    
    final camera = _cameras.firstWhere(
      (c) => c.lensDirection == direction,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      _currentDirection = camera.lensDirection;
      _isInitialized = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to initialize camera: $e';
      _isInitialized = false;
    }

    notifyListeners();
  }

  
  Future<void> switchCamera() async {
    final newDirection =
        _currentDirection == CameraLensDirection.front
            ? CameraLensDirection.back
            : CameraLensDirection.front;

    await _initCamera(newDirection);
  }


  Future<XFile?> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;

    try {
      return await _controller!.takePicture();
    } catch (e) {
      _errorMessage = 'Capture failed: $e';
      notifyListeners();
      return null;
    }
  }

 

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
