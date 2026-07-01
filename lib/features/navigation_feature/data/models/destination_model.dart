/// Represents a navigation destination with a name and GPS coordinates.
class DestinationModel {
  final String name;
  final double latitude;
  final double longitude;

  const DestinationModel({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() => 'DestinationModel($name, $latitude, $longitude)';
}
