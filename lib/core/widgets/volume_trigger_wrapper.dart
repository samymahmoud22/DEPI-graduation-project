import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/services/volume_key_service.dart';
import '/../features/voice_assistant/domain/presentation/controller/voice_assistant_controller.dart';


class VolumeTriggerWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const VolumeTriggerWrapper({super.key, required this.child});

  @override
  ConsumerState<VolumeTriggerWrapper> createState() => _VolumeTriggerWrapperState();
}

class _VolumeTriggerWrapperState extends ConsumerState<VolumeTriggerWrapper> {
  late final VolumeKeyService _volumeKeyService;
  StreamSubscription<void>? _longPressSub;

  @override
  void initState() {
    super.initState();
    _volumeKeyService = VolumeKeyService();
    _volumeKeyService.attach();

    _longPressSub = _volumeKeyService.onLongPress.listen((_) {
      _onVolumeUpLongPress();
    });
  }

  void _onVolumeUpLongPress() {
    final voiceController = ref.read(voiceAssistantControllerProvider);
    // Avoid triggering while already processing a command.
    if (voiceController.isListening) return;
    voiceController.handleVolumeUpTrigger(context);
  }

  @override
  void dispose() {
    _longPressSub?.cancel();
    _volumeKeyService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
