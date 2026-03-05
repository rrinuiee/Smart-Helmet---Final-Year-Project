import 'package:latlong2/latlong.dart';

class NavigationData {
  final LatLng? destination;
  final List<LatLng> route;
  final double totalDistance;
  final Duration estimatedTime;
  final String currentInstruction;
  final double distanceToNextTurn;
  final NavigationStatus status;

  NavigationData({
    this.destination,
    required this.route,
    required this.totalDistance,
    required this.estimatedTime,
    required this.currentInstruction,
    required this.distanceToNextTurn,
    required this.status,
  });

  factory NavigationData.empty() {
    return NavigationData(
      route: [],
      totalDistance: 0.0,
      estimatedTime: Duration.zero,
      currentInstruction: '',
      distanceToNextTurn: 0.0,
      status: NavigationStatus.idle,
    );
  }

  factory NavigationData.mockNavigation() {
    return NavigationData(
      destination: const LatLng(12.9716, 77.5946), // Bangalore
      route: [
        const LatLng(12.8539832, 77.7786213),
        const LatLng(12.9000, 77.7500),
        const LatLng(12.9716, 77.5946),
      ],
      totalDistance: 15.2,
      estimatedTime: const Duration(minutes: 25),
      currentInstruction: 'Turn right in 200m',
      distanceToNextTurn: 0.2,
      status: NavigationStatus.navigating,
    );
  }
}

enum NavigationStatus {
  idle,
  calculating,
  navigating,
  arrived,
  error,
}

class NavigationInstruction {
  final String text;
  final String direction;
  final double distance;
  final LatLng location;

  NavigationInstruction({
    required this.text,
    required this.direction,
    required this.distance,
    required this.location,
  });
}