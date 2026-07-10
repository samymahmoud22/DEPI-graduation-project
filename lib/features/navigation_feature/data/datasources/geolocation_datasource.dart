import 'package:geolocator/geolocator.dart';

/// Wraps the [Geolocator] package to provide GPS location access
/// with built-in permission handling.
class GeolocationDatasource {
  /// Checks and requests location permissions, then returns the
  /// device's current [Position].
  ///
  /// Throws a [String] error message on permission denial or
  /// if location services are disabled.
  Future<Position> getCurrentPosition() async {
    // 1. Check if location services are enabled.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled. Please enable them.';
    }

    // 2. Check / request permission.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission denied.';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission permanently denied. Please enable in settings.';
    }

    // 3. Get the current position.
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Returns a live stream of position updates.
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // minimum meters before an update
      ),
    );
  }
}
