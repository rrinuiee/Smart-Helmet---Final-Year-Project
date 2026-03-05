import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  static final RouteService _instance = RouteService._internal();
  factory RouteService() => _instance;
  RouteService._internal();

  // OpenRouteService API endpoint (free tier, no API key required for basic usage)
  static const String _baseUrl = 'https://api.openrouteservice.org/v2/directions';
  
  // For production, you should get a free API key from openrouteservice.org
  // Using demo key - replace with your own for production use
  static const String _apiKey = '5b3ce3597851110001cf6248a4b8205470f64d6aa0b0c4d8b1c4c8b8';

  Future<RouteResult> getRoute({
    required LatLng origin,
    required LatLng destination,
    String profile = 'driving-car', // driving-car, cycling-regular, foot-walking
  }) async {
    try {
      final url = '$_baseUrl/$profile';
      
      final body = {
        'coordinates': [
          [origin.longitude, origin.latitude],
          [destination.longitude, destination.latitude]
        ],
        'format': 'json',
        'instructions': true,
        'geometry': true,
        'elevation': false,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _apiKey,
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RouteResult.fromOpenRouteService(data);
      } else if (response.statusCode == 429) {
        // Rate limit exceeded, fallback to OSRM
        return await _getRouteFromOSRM(origin, destination);
      } else {
        throw Exception('Failed to get route: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to OSRM if OpenRouteService fails
      return await _getRouteFromOSRM(origin, destination);
    }
  }

  // Fallback to OSRM (Open Source Routing Machine) - free, no API key required
  Future<RouteResult> _getRouteFromOSRM(LatLng origin, LatLng destination) async {
    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}'
          '?overview=full&geometries=geojson&steps=true';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RouteResult.fromOSRM(data);
      } else {
        throw Exception('Failed to get route from OSRM: ${response.statusCode}');
      }
    } catch (e) {
      // Final fallback to simple route
      return RouteResult.fallback(origin, destination);
    }
  }
}

class RouteResult {
  final List<LatLng> coordinates;
  final double distance; // in kilometers
  final Duration duration;
  final List<RouteInstruction> instructions;
  final LatLng? origin;
  final LatLng? destination;

  RouteResult({
    required this.coordinates,
    required this.distance,
    required this.duration,
    required this.instructions,
    this.origin,
    this.destination,
  });

  factory RouteResult.fromOpenRouteService(Map<String, dynamic> data) {
    final route = data['routes'][0];
    final geometry = route['geometry'];
    final summary = route['summary'];
    final segments = route['segments'] as List;

    // Parse coordinates from geometry
    List<LatLng> coordinates = [];
    if (geometry is List) {
      coordinates = geometry.map<LatLng>((coord) => 
        LatLng(coord[1].toDouble(), coord[0].toDouble())
      ).toList();
    }

    // Parse instructions
    List<RouteInstruction> instructions = [];
    for (var segment in segments) {
      final steps = segment['steps'] as List;
      for (var step in steps) {
        instructions.add(RouteInstruction.fromOpenRouteService(step));
      }
    }

    return RouteResult(
      coordinates: coordinates,
      distance: (summary['distance'] as num).toDouble() / 1000, // Convert to km
      duration: Duration(seconds: (summary['duration'] as num).toInt()),
      instructions: instructions,
    );
  }

  factory RouteResult.fromOSRM(Map<String, dynamic> data) {
    final route = data['routes'][0];
    final geometry = route['geometry'];
    final legs = route['legs'] as List;

    // Parse coordinates from GeoJSON geometry
    List<LatLng> coordinates = [];
    if (geometry['coordinates'] is List) {
      coordinates = (geometry['coordinates'] as List).map<LatLng>((coord) => 
        LatLng(coord[1].toDouble(), coord[0].toDouble())
      ).toList();
    }

    // Parse instructions from legs
    List<RouteInstruction> instructions = [];
    for (var leg in legs) {
      final steps = leg['steps'] as List;
      for (var step in steps) {
        instructions.add(RouteInstruction.fromOSRM(step));
      }
    }

    return RouteResult(
      coordinates: coordinates,
      distance: (route['distance'] as num).toDouble() / 1000, // Convert to km
      duration: Duration(seconds: (route['duration'] as num).toInt()),
      instructions: instructions,
    );
  }

  factory RouteResult.fallback(LatLng origin, LatLng destination) {
    // Simple fallback route with basic instructions
    final coordinates = [
      origin,
      LatLng(
        (origin.latitude + destination.latitude) / 2,
        (origin.longitude + destination.longitude) / 2,
      ),
      destination,
    ];

    // Calculate approximate distance using Haversine formula
    const Distance distance = Distance();
    final totalDistance = distance.as(LengthUnit.Kilometer, origin, destination);
    final estimatedDuration = Duration(minutes: (totalDistance * 2).round()); // ~30 km/h

    return RouteResult(
      coordinates: coordinates,
      distance: totalDistance,
      duration: estimatedDuration,
      instructions: [
        RouteInstruction(
          instruction: 'Head towards destination',
          distance: totalDistance * 1000, // Convert to meters
          duration: estimatedDuration,
          type: 'straight',
        ),
        RouteInstruction(
          instruction: 'You have arrived at your destination',
          distance: 0,
          duration: Duration.zero,
          type: 'arrive',
        ),
      ],
      origin: origin,
      destination: destination,
    );
  }
}

class RouteInstruction {
  final String instruction;
  final double distance; // in meters
  final Duration duration;
  final String type;
  final LatLng? location;

  RouteInstruction({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.type,
    this.location,
  });

  factory RouteInstruction.fromOpenRouteService(Map<String, dynamic> data) {
    return RouteInstruction(
      instruction: data['instruction'] ?? 'Continue',
      distance: (data['distance'] as num?)?.toDouble() ?? 0.0,
      duration: Duration(seconds: (data['duration'] as num?)?.toInt() ?? 0),
      type: data['type']?.toString() ?? 'straight',
    );
  }

  factory RouteInstruction.fromOSRM(Map<String, dynamic> data) {
    return RouteInstruction(
      instruction: data['maneuver']?['instruction'] ?? 'Continue',
      distance: (data['distance'] as num?)?.toDouble() ?? 0.0,
      duration: Duration(seconds: (data['duration'] as num?)?.toInt() ?? 0),
      type: data['maneuver']?['type']?.toString() ?? 'straight',
    );
  }
}