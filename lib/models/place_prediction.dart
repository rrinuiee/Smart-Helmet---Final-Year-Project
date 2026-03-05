class PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final List<String> types;
  final bool isCurrentLocation;
  final double? latitude;
  final double? longitude;

  PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.types,
    this.isCurrentLocation = false,
    this.latitude,
    this.longitude,
  });

  factory PlacePrediction.currentLocation() {
    return PlacePrediction(
      placeId: 'current_location',
      mainText: '📍 Current Location',
      secondaryText: 'Use my current location',
      types: ['current_location'],
      isCurrentLocation: true,
    );
  }

  factory PlacePrediction.fromNominatimJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    
    // Extract main text (name or road)
    String mainText = json['name'] as String? ?? 
                     json['display_name']?.toString().split(',').first ?? 
                     'Unknown';
    
    // Extract secondary text (city, state, country)
    List<String> secondaryParts = [];
    if (address != null) {
      if (address['city'] != null) secondaryParts.add(address['city']);
      if (address['state'] != null) secondaryParts.add(address['state']);
      if (address['country'] != null) secondaryParts.add(address['country']);
    }
    
    String secondaryText = secondaryParts.isNotEmpty 
        ? secondaryParts.join(', ')
        : json['display_name']?.toString().split(',').skip(1).take(2).join(',').trim() ?? '';

    return PlacePrediction(
      placeId: json['place_id']?.toString() ?? json['osm_id']?.toString() ?? '',
      mainText: mainText,
      secondaryText: secondaryText,
      types: [json['type'] as String? ?? 'place'],
      latitude: double.tryParse(json['lat']?.toString() ?? ''),
      longitude: double.tryParse(json['lon']?.toString() ?? ''),
    );
  }

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    // Fallback for old format
    return PlacePrediction.fromNominatimJson(json);
  }
}
