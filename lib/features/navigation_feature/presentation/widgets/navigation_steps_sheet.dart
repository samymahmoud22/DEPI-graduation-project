import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/route_step_model.dart';

/// Displays the current navigation step as a prominent card
/// with a maneuver icon, instruction text, and distance.
class NavigationStepCard extends StatelessWidget {
  final RouteStepModel step;
  final int stepIndex;
  final int totalSteps;

  const NavigationStepCard({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryButton.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step counter
          Text(
            'الخطوة ${stepIndex + 1} من $totalSteps',
            style: const TextStyle(
              color: AppColors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),

          // Maneuver icon
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryButton,
            ),
            child: Icon(
              _maneuverIcon(step.maneuver),
              color: AppColors.white,
              size: 32,
            ),
          ),

          const SizedBox(height: 16),

          // Spoken instruction (Arabic)
          Text(
            step.spokenInstruction,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          // Raw instruction (extra detail)
          if (step.instruction.isNotEmpty &&
              step.instruction != step.spokenInstruction)
            Text(
              step.instruction,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: AppColors.white70,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const SizedBox(height: 12),

          // Distance badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              step.distance,
              style: const TextStyle(
                color: AppColors.primaryButton,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _maneuverIcon(String maneuver) {
    switch (maneuver) {
      case 'turn-right':
      case 'turn-slight-right':
      case 'turn-sharp-right':
      case 'fork-right':
      case 'roundabout-right':
        return Icons.turn_right;
      case 'turn-left':
      case 'turn-slight-left':
      case 'turn-sharp-left':
      case 'fork-left':
      case 'roundabout-left':
        return Icons.turn_left;
      case 'uturn-right':
      case 'uturn-left':
        return Icons.u_turn_left;
      case 'straight':
      case 'merge':
        return Icons.straight;
      default:
        return Icons.navigation_rounded;
    }
  }
}
