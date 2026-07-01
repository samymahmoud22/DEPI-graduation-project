import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

/// Wraps the [geocoding] package and fallback Google Geocoding API/OSM Nominatim
/// to convert between human-readable addresses and GPS coordinates.
class GeocodingDatasource {
  final Dio _dio = Dio();

  /// Reverse-geocodes [lat]/[lng] into a human-readable address string.
  /// Returns a formatted address or `'Unknown location'` on failure.
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    final apiKey = dotenv.env['GOOGLE_DIRECTIONS_API_KEY'] ?? '';
    if (apiKey.isNotEmpty) {
      try {
        final response = await _dio.get(
          'https://maps.googleapis.com/maps/api/geocode/json',
          queryParameters: {
            'latlng': '$lat,$lng',
            'key': apiKey,
            'language': 'ar',
          },
        );
        if (response.statusCode == 200) {
          final data = response.data;
          if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
            return data['results'][0]['formatted_address'] as String;
          } else {
            debugPrint('Google Reverse Geocoding API returned status: ${data['status']}');
          }
        }
      } catch (e) {
        debugPrint('Google Reverse Geocoding API Error: $e');
      }
    }

    // Fallback 1: OpenStreetMap Nominatim
    try {
      debugPrint('Falling back to OpenStreetMap Nominatim for coordinates: $lat, $lng');
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat.toString(),
          'lon': lng.toString(),
          'format': 'json',
          'accept-language': 'ar',
        },
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null && response.data['display_name'] != null) {
        return response.data['display_name'] as String;
      }
    } catch (e) {
      debugPrint('OSM Nominatim Reverse Geocoding Error: $e');
    }

    // Fallback 2: Native geocoding
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return 'Unknown location';

      final p = placemarks.first;
      // Build a readable address from available parts.
      final parts = <String>[
        if (p.street != null && p.street!.isNotEmpty) p.street!,
        if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality!,
        if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
        if (p.country != null && p.country!.isNotEmpty) p.country!,
      ];
      return parts.isNotEmpty ? parts.join(', ') : 'Unknown location';
    } catch (_) {
      return 'Unknown location';
    }
  }

  /// Forward-geocodes an [address] string into coordinates.
  /// Returns the first matching [geocoding.Location] or `null`.
  Future<geocoding.Location?> getCoordinatesFromAddress(String address) async {
    final apiKey = dotenv.env['GOOGLE_DIRECTIONS_API_KEY'] ?? '';
    if (apiKey.isNotEmpty) {
      try {
        final response = await _dio.get(
          'https://maps.googleapis.com/maps/api/geocode/json',
          queryParameters: {
            'address': address,
            'key': apiKey,
            'language': 'ar',
          },
        );
        if (response.statusCode == 200) {
          final data = response.data;
          if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
            final locationData = data['results'][0]['geometry']['location'];
            final lat = (locationData['lat'] as num).toDouble();
            final lng = (locationData['lng'] as num).toDouble();
            return geocoding.Location(
              latitude: lat,
              longitude: lng,
              timestamp: DateTime.now(),
            );
          } else {
            debugPrint('Google Geocoding API returned status: ${data['status']}');
          }
        }
      } catch (e) {
        debugPrint('Google Geocoding API Error: $e');
      }
    }

    // Fallback 1: OpenStreetMap Nominatim
    try {
      debugPrint('Falling back to OpenStreetMap Nominatim for address: $address');
      final result = await _queryNominatim(address);
      if (result != null) return result;

      // Clean stop words and try again
      final cleaned = address
          .replaceAll(RegExp(r'\s+ف(ى|ي)\s+'), ' ')
          .replaceAll(RegExp(r'\s+ب(ـ)?\s+'), ' ')
          .trim();
      if (cleaned != address) {
        debugPrint('Trying Nominatim with cleaned address: $cleaned');
        final cleanedResult = await _queryNominatim(cleaned);
        if (cleanedResult != null) return cleanedResult;
      }
    } catch (e) {
      debugPrint('OSM Nominatim Geocoding Error: $e');
    }

    // Fallback 2: Native geocoding
    try {
      debugPrint('Falling back to native geocoding for address: $address');
      final locations = await geocoding.locationFromAddress(address);
      return locations.isNotEmpty ? locations.first : null;
    } catch (_) {
      return null;
    }
  }

  Future<geocoding.Location?> _queryNominatim(String address) async {
    final response = await _dio.get(
      'https://nominatim.openstreetmap.org/search',
      queryParameters: {
        'q': address,
        'format': 'json',
        'limit': '1',
        'accept-language': 'ar',
      },
      options: Options(
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      ),
    );
    if (response.statusCode == 200 && response.data is List && (response.data as List).isNotEmpty) {
      final first = (response.data as List).first;
      final lat = double.parse(first['lat'].toString());
      final lon = double.parse(first['lon'].toString());
      return geocoding.Location(
        latitude: lat,
        longitude: lon,
        timestamp: DateTime.now(),
      );
    }
    return null;
  }
}

