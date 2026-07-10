/// Represents a single step/maneuver in a navigation route.
class RouteStepModel {
  /// Arabic instruction text from Google Directions API.
  /// e.g. "اتجه شمالاً في شارع التحرير"
  final String instruction;

  /// Human-readable distance string. e.g. "200 م" or "1.5 كم"
  final String distance;

  /// Distance in meters (used for proximity calculations).
  final int distanceMeters;

  /// Human-readable duration string. e.g. "3 دقائق"
  final String duration;

  /// Maneuver type from the API: "turn-right", "turn-left",
  /// "straight", "roundabout-right", etc.  May be empty for
  /// the first/last step.
  final String maneuver;

  /// Start coordinates of this step.
  final double startLat;
  final double startLng;

  /// End coordinates of this step.
  final double endLat;
  final double endLng;

  const RouteStepModel({
    required this.instruction,
    required this.distance,
    required this.distanceMeters,
    required this.duration,
    required this.maneuver,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
  });

  /// Builds a concise Arabic spoken instruction that combines
  /// the maneuver with the distance.
  ///
  /// Example output: "خش يمين، فاضل 200 متر"
  String get spokenInstruction {
    final maneuverArabic = _maneuverToArabic(maneuver);
    if (maneuverArabic.isNotEmpty) {
      return '$maneuverArabic، $distance';
    }
    // Fall back to the raw Google instruction.
    return instruction;
  }

  static String _maneuverToArabic(String maneuver) {
    switch (maneuver) {
      case 'turn-right':
        return 'خش يمين';
      case 'turn-left':
        return 'خش شمال';
      case 'turn-slight-right':
        return 'خد يمين شوية';
      case 'turn-slight-left':
        return 'خد شمال شوية';
      case 'turn-sharp-right':
        return 'لف يمين حاد';
      case 'turn-sharp-left':
        return 'لف شمال حاد';
      case 'uturn-right':
      case 'uturn-left':
        return 'لف لف';
      case 'roundabout-right':
      case 'roundabout-left':
        return 'خش الدوران';
      case 'straight':
        return 'امشي طوالي';
      case 'merge':
        return 'ادخل على الطريق';
      case 'fork-right':
        return 'خد المفترق يمين';
      case 'fork-left':
        return 'خد المفترق شمال';
      default:
        return '';
    }
  }

  @override
  String toString() =>
      'RouteStepModel(maneuver: $maneuver, distance: $distance, '
      'instruction: $instruction)';
}
