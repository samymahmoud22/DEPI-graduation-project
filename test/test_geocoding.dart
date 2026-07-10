import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:visionmate/features/navigation_feature/data/datasources/geocoding_datasource.dart';
import 'package:visionmate/features/navigation_feature/data/datasources/routes_datasource.dart';

void main() {
  setUpAll(() async {
    final envFile = File('.env');
    if (envFile.existsSync()) {
      dotenv.testLoad(fileInput: envFile.readAsStringSync());
    }
  });

  test('GeocodingDatasource forward-geocodes "شارع الجلاء فى المنصورة" successfully', () async {
    final geocoding = GeocodingDatasource();
    final location = await geocoding.getCoordinatesFromAddress('شارع الجلاء فى المنصورة');
    
    expect(location, isNotNull);
    print("Resolved coordinates: ${location!.latitude}, ${location.longitude}");
    expect(location.latitude, closeTo(31.038, 0.1));
    expect(location.longitude, closeTo(31.373, 0.1));
  });

  test('RoutesDatasource fetches route via OSRM fallback successfully', () async {
    final routes = RoutesDatasource();
    // Use OSRM fallback to calculate route from Mansoura nearby to El Galaa Street
    final session = await routes.getRoute(
      originLat: 31.04,
      originLng: 31.38,
      destLat: 31.0381519,
      destLng: 31.3738830,
      destinationName: 'شارع الجلاء فى المنصورة',
    );

    expect(session, isNotNull);
    expect(session!.steps.isNotEmpty, true);
    print("Session total distance: ${session.totalDistance}");
    print("Session total duration: ${session.totalDuration}");
    print("First step instruction: ${session.steps.first.spokenInstruction}");
  });
}
