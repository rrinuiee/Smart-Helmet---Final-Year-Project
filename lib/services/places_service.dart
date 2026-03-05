import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_prediction.dart';

class PlacesService {
  static const String _baseUrl = 'nominatim.openstreetmap.org';
  
  Future<List<PlacePrediction>> getPlacePredictions(
    String input,
    {
    double? latitude,
    double? longitude,
    double radius = 500.0,
  }) async {
    try {
      if (input.isEmpty || input.length < 3) {
        return [];
      }

      final queryParams = {
        'q': input,
        'format': 'json',
        'addressdetails': '1',
        'limit': '10',
        'countrycodes': 'in', // India
      };

      // Add location bias if provided
      if (latitude != null && longitude != null) {
        queryParams['viewbox'] = '${longitude - 0.1},${latitude - 0.1},${longitude + 0.1},${latitude + 0.1}';
        queryParams['bounded'] = '1';
      }

      final uri = Uri.https(_baseUrl, '/search', queryParams);
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'EngottaApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => PlacePrediction.fromNominatimJson(item))
            .toList();
      } else {
        print('Nominatim API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching place predictions: $e');
      return [];
    }
  }
}
