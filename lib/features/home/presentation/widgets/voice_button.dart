import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';

class VoiceButton extends ConsumerWidget {
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isListening;

  const VoiceButton({
    super.key,
    required this.onTap,
    required this.onLongPress,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            width: 106,
            height: 106,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF214D80),
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening ? AppColors.green : AppColors.micCircle,
                ),
                child: Icon(
                  isListening ? Icons.hearing_rounded : Icons.mic_none_rounded,
                  color: AppColors.white,
                  size: 38,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 150,
          height: 32,
          child: ElevatedButton(
            onPressed: onTap,
            child: Text(isListening ? t.get('listening') : t.get('tap_to_speak')),
          ),
        ),
      ],
    );
  }
}