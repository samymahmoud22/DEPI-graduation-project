import 'route_step_model.dart';

/// Holds the full result of a directions query: the ordered list
/// of steps plus aggregate distance / duration information.
class NavigationSessionModel {
  /// Ordered list of route steps (maneuvers).
  final List<RouteStepModel> steps;

  /// Human-readable total distance. e.g. "2.5 كم"
  final String totalDistance;

  /// Total distance in meters.
  final int totalDistanceMeters;

  /// Human-readable total duration. e.g. "30 دقيقة"
  final String totalDuration;

  /// Name of the destination the user asked for.
  final String destinationName;

  const NavigationSessionModel({
    required this.steps,
    required this.totalDistance,
    required this.totalDistanceMeters,
    required this.totalDuration,
    required this.destinationName,
  });

  @override
  String toString() =>
      'NavigationSessionModel($destinationName, '
      '${steps.length} steps, $totalDistance, $totalDuration)';
}
