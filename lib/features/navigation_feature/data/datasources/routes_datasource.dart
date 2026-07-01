import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/route_step_model.dart';
import '../models/navigation_session_model.dart';

/// Calls the Google Directions API and parses the response into
/// [NavigationSessionModel] containing turn-by-turn steps.
class RoutesDatasource {
  final Dio _dio = Dio();

  static const _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  /// Fetches walking directions from [originLat],[originLng] to
  /// [destLat],[destLng].
  /// Fetches walking directions from [originLat],[originLng] to
  /// [destLat],[destLng].
  ///
  /// Returns a [NavigationSessionModel] with Arabic instructions
  /// or `null` if no route was found.
  Future<NavigationSessionModel?> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required String destinationName,
  }) async {
    final apiKey = dotenv.env['GOOGLE_DIRECTIONS_API_KEY'] ?? '';
    bool googleDirectionsFailed = false;

    if (apiKey.isNotEmpty) {
      try {
        debugPrint('RoutesDatasource: Querying Google Directions API (walking)...');
        var response = await _dio.get(
          _baseUrl,
          queryParameters: {
            'origin': '$originLat,$originLng',
            'destination': '$destLat,$destLng',
            'mode': 'walking',
            'language': 'ar', // Arabic instructions
            'key': apiKey,
          },
        );

        var data = response.data is String
            ? json.decode(response.data as String) as Map<String, dynamic>
            : response.data as Map<String, dynamic>;

        var status = data['status'] as String?;
        
        // If walking mode returns ZERO_RESULTS (very common for long distances or unmapped pedestrian paths in Egypt)
        // try fallback to driving mode.
        if (status == 'ZERO_RESULTS') {
          debugPrint('RoutesDatasource: Walking directions returned ZERO_RESULTS, trying driving mode fallback...');
          response = await _dio.get(
            _baseUrl,
            queryParameters: {
              'origin': '$originLat,$originLng',
              'destination': '$destLat,$destLng',
              'mode': 'driving',
              'language': 'ar',
              'key': apiKey,
            },
          );
          data = response.data is String
              ? json.decode(response.data as String) as Map<String, dynamic>
              : response.data as Map<String, dynamic>;
          status = data['status'] as String?;
        }

        if (status == 'OK') {
          final routes = data['routes'] as List<dynamic>?;
          if (routes != null && routes.isNotEmpty) {
            final route = routes.first as Map<String, dynamic>;
            final legs = route['legs'] as List<dynamic>;
            if (legs.isNotEmpty) {
              final leg = legs.first as Map<String, dynamic>;
              return _parseGoogleRouteLeg(leg, destinationName);
            }
          }
        } else {
          debugPrint('Directions API returned non-OK status: $status');
          if (status == 'REQUEST_DENIED') {
            googleDirectionsFailed = true;
          }
        }
      } catch (e) {
        debugPrint('RoutesDatasource Google API error: $e');
        googleDirectionsFailed = true;
      }
    } else {
      googleDirectionsFailed = true;
    }

    // Fallback: Open Source Routing Machine (OSRM)
    if (googleDirectionsFailed || apiKey.isEmpty) {
      debugPrint('RoutesDatasource: Google Directions API failed or is not available. Falling back to OSRM...');
      return await _getRouteFromOSRM(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
        destinationName: destinationName,
      );
    }

    return null;
  }

  NavigationSessionModel _parseGoogleRouteLeg(Map<String, dynamic> leg, String destinationName) {
    // ── Parse aggregate info ──────────────────────────────────────
    final totalDistance = leg['distance']?['text'] as String? ?? '';
    final totalDistanceMeters = leg['distance']?['value'] as int? ?? 0;
    final totalDuration = leg['duration']?['text'] as String? ?? '';

    // ── Parse individual steps ────────────────────────────────────
    final rawSteps = leg['steps'] as List<dynamic>? ?? [];
    final steps = rawSteps.map((s) {
      final step = s as Map<String, dynamic>;

      // Strip HTML tags from instruction.
      final rawHtml = step['html_instructions'] as String? ?? '';
      final instruction = rawHtml.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();

      final distText = step['distance']?['text'] as String? ?? '';
      final distMeters = step['distance']?['value'] as int? ?? 0;
      final durText = step['duration']?['text'] as String? ?? '';
      final maneuver = step['maneuver'] as String? ?? '';

      final startLoc = step['start_location'] as Map<String, dynamic>?;
      final endLoc = step['end_location'] as Map<String, dynamic>?;

      return RouteStepModel(
        instruction: instruction,
        distance: distText,
        distanceMeters: distMeters,
        duration: durText,
        maneuver: maneuver,
        startLat: (startLoc?['lat'] as num?)?.toDouble() ?? 0,
        startLng: (startLoc?['lng'] as num?)?.toDouble() ?? 0,
        endLat: (endLoc?['lat'] as num?)?.toDouble() ?? 0,
        endLng: (endLoc?['lng'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

    return NavigationSessionModel(
      steps: steps,
      totalDistance: totalDistance,
      totalDistanceMeters: totalDistanceMeters,
      totalDuration: totalDuration,
      destinationName: destinationName,
    );
  }

  Future<NavigationSessionModel?> _getRouteFromOSRM({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required String destinationName,
  }) async {
    final url = 'http://router.project-osrm.org/route/v1/foot/$originLng,$originLat;$destLng,$destLat';
    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'steps': 'true',
          'geometries': 'geojson',
          'overview': 'full',
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? json.decode(response.data as String) as Map<String, dynamic>
            : response.data as Map<String, dynamic>;

        if (data['code'] == 'Ok') {
          final routes = data['routes'] as List<dynamic>?;
          if (routes == null || routes.isEmpty) return null;

          final route = routes.first as Map<String, dynamic>;
          final legs = route['legs'] as List<dynamic>;
          if (legs.isEmpty) return null;

          final leg = legs.first as Map<String, dynamic>;

          final totalDistanceMeters = (leg['distance'] as num?)?.round() ?? 0;
          final totalDurationSeconds = (leg['duration'] as num?)?.round() ?? 0;

          final totalDistance = totalDistanceMeters < 1000
              ? '$totalDistanceMeters م'
              : '${(totalDistanceMeters / 1000).toStringAsFixed(1)} كم';

          final totalDuration = totalDurationSeconds < 60
              ? 'أقل من دقيقة'
              : '${(totalDurationSeconds / 60).round()} دقيقة';

          final rawSteps = leg['steps'] as List<dynamic>? ?? [];
          final steps = <RouteStepModel>[];

          for (var i = 0; i < rawSteps.length; i++) {
            final s = rawSteps[i] as Map<String, dynamic>;

            final startLoc = s['maneuver']?['location'] as List<dynamic>?;
            final startLat = startLoc != null && startLoc.length >= 2
                ? (startLoc[1] as num).toDouble()
                : 0.0;
            final startLng = startLoc != null && startLoc.length >= 2
                ? (startLoc[0] as num).toDouble()
                : 0.0;

            double endLat = destLat;
            double endLng = destLng;
            if (i < rawSteps.length - 1) {
              final nextS = rawSteps[i + 1] as Map<String, dynamic>;
              final nextStartLoc = nextS['maneuver']?['location'] as List<dynamic>?;
              if (nextStartLoc != null && nextStartLoc.length >= 2) {
                endLat = (nextStartLoc[1] as num).toDouble();
                endLng = (nextStartLoc[0] as num).toDouble();
              }
            }

            final distVal = (s['distance'] as num?)?.round() ?? 0;
            final durVal = (s['duration'] as num?)?.round() ?? 0;

            final distText = distVal < 1000
                ? '$distVal م'
                : '${(distVal / 1000).toStringAsFixed(1)} كم';
            final durText = durVal < 60
                ? 'أقل من دقيقة'
                : '${(durVal / 60).round()} دقيقة';

            final modifier = s['maneuver']?['modifier'] as String? ?? '';
            String maneuverVal = '';
            switch (modifier) {
              case 'left':
                maneuverVal = 'turn-left';
                break;
              case 'right':
                maneuverVal = 'turn-right';
                break;
              case 'sharp left':
                maneuverVal = 'turn-sharp-left';
                break;
              case 'sharp right':
                maneuverVal = 'turn-sharp-right';
                break;
              case 'slight left':
                maneuverVal = 'turn-slight-left';
                break;
              case 'slight right':
                maneuverVal = 'turn-slight-right';
                break;
              case 'uturn':
                maneuverVal = 'uturn-left';
                break;
              case 'straight':
                maneuverVal = 'straight';
                break;
              default:
                maneuverVal = '';
            }

            final instruction = _getArabicInstruction(s);

            steps.add(RouteStepModel(
              instruction: instruction,
              distance: distText,
              distanceMeters: distVal,
              duration: durText,
              maneuver: maneuverVal,
              startLat: startLat,
              startLng: startLng,
              endLat: endLat,
              endLng: endLng,
            ));
          }

          return NavigationSessionModel(
            steps: steps,
            totalDistance: totalDistance,
            totalDistanceMeters: totalDistanceMeters,
            totalDuration: totalDuration,
            destinationName: destinationName,
          );
        }
      }
    } catch (e) {
      debugPrint('OSRM Routing Error: $e');
    }
    return null;
  }

  String _getArabicInstruction(Map<String, dynamic> step) {
    final maneuver = step['maneuver'] as Map<String, dynamic>? ?? {};
    final type = maneuver['type'] as String? ?? '';
    final modifier = maneuver['modifier'] as String? ?? '';
    final name = step['name'] as String? ?? '';
    final distance = (step['distance'] as num?)?.round() ?? 0;

    final streetName = name.isNotEmpty ? name : 'طريق غير مسمى';

    if (type == 'depart') {
      return 'ابدأ التحرك على $streetName لمسافة $distance متر';
    }
    if (type == 'arrive') {
      return 'وصلت إلى وجهتك.';
    }

    String direction = '';
    switch (modifier) {
      case 'left':
        direction = 'انعطف يساراً';
        break;
      case 'right':
        direction = 'انعطف يميناً';
        break;
      case 'sharp left':
        direction = 'انعطف يساراً حاداً';
        break;
      case 'sharp right':
        direction = 'انعطف يميناً حاداً';
        break;
      case 'slight left':
        direction = 'انحرف يساراً قليلاً';
        break;
      case 'slight right':
        direction = 'انحرف يميناً قليلاً';
        break;
      case 'uturn':
        direction = 'در للخلف';
        break;
      case 'straight':
        direction = 'اكمل خط السير مستقيماً';
        break;
      default:
        direction = 'تابع السير';
    }

    if (type == 'turn') {
      return '$direction نحو $streetName لمسافة $distance متر';
    } else if (type == 'new name') {
      return 'واصل السير على $streetName لمسافة $distance متر';
    } else if (type == 'end of road') {
      return 'عند نهاية الطريق، $direction نحو $streetName لمسافة $distance متر';
    }

    return 'تابع السير على $streetName لمسافة $distance متر';
  }
}
