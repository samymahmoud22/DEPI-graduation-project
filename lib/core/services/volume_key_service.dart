import 'dart:async';

import 'package:flutter/services.dart';


class VolumeKeyService {
 
  static const Duration longPressDuration = Duration(milliseconds: 1500);

  Timer? _holdTimer;
  bool _isHolding = false;

  final StreamController<void> _longPressController =
      StreamController<void>.broadcast();

  
  Stream<void> get onLongPress => _longPressController.stream;

  
  bool get isLongPressActive => _isHolding;

  
  void attach() {
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  
  void detach() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _holdTimer?.cancel();
    _holdTimer = null;
    _isHolding = false;
  }

  
  void dispose() {
    detach();
    _longPressController.close();
  }

 

  bool _handleKeyEvent(KeyEvent event) {
   
    if (event.logicalKey != LogicalKeyboardKey.audioVolumeUp) {
      return false; // let the framework handle other keys
    }

    if (event is KeyDownEvent) {

      if (_holdTimer != null) return true;

      _holdTimer = Timer(longPressDuration, () {
        _isHolding = true;
        _longPressController.add(null);
      });

      return true; 
    }

    if (event is KeyUpEvent) {
      _holdTimer?.cancel();
      _holdTimer = null;
      _isHolding = false;
      return true;
    }

    
    return true;
  }
}
