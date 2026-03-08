import 'dart:async';
import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../models/navigation_data.dart';
import '../models/place_prediction.dart';
import 'location_service.dart';
import 'helmet_service.dart';
import 'route_service.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final LocationService _locationService = LocationService();
  final HelmetService _helmetService = HelmetService();
  final RouteService _routeService = RouteService();
  
  final StreamController<NavigationData> _navigationController = StreamController<NavigationData>.broadcast();
  Stream<NavigationData> get navigationStream => _navigationController.stream;

  NavigationData _currentNavigation = NavigationData.empty();
  Timer? _navigationTimer;
  RouteResult? _currentRoute;
  int _currentInstructionIndex = 0;

  NavigationData get currentNavigation => _currentNavigation;

  Future<NavigationData> startNavigation(PlacePrediction destination) async {
    if (destination.latitude == null || destination.longitude == null) {
      throw Exception('Invalid destination coordinates');
    }

    try {
      // Update status to calculating
      _currentNavigation = NavigationData(
        destination: LatLng(destination.latitude!, destination.longitude!),
        route: [],
        totalDistance: 0.0,
        estimatedTime: Duration.zero,
        currentInstruction: 'Calculating route...',
        distanceToNextTurn: 0.0,
        status: NavigationStatus.calculating,
      );
      _navigationController.add(_currentNavigation);

      final currentLocation = await _locationService.getCurrentLocation();
      final destinationLatLng = LatLng(destination.latitude!, destination.longitude!);

      // Get real route from routing service
      _currentRoute = await _routeService.getRoute(
        origin: currentLocation,
        destination: destinationLatLng,
        profile: 'driving-car', // Use driving profile for helmet navigation
      );

      _currentInstructionIndex = 0;

      _currentNavigation = NavigationData(
        destination: destinationLatLng,
        route: _currentRoute!.coordinates,
        totalDistance: _currentRoute!.distance,
        estimatedTime: _currentRoute!.duration,
        currentInstruction: _getCurrentInstruction(),
        distanceToNextTurn: _getDistanceToNextTurn(currentLocation),
        status: NavigationStatus.navigating,
      );

      _navigationController.add(_currentNavigation);
      _startNavigationUpdates();

      // Send initial instruction to helmet with complete data
      await _helmetService.sendNavigationDataComplete(
        instruction: _currentNavigation.currentInstruction,
        distanceToNextTurn: _currentNavigation.distanceToNextTurn,
        totalDistance: _currentNavigation.totalDistance,
        estimatedTimeMinutes: _currentNavigation.estimatedTime.inMinutes,
        status: 'navigating',
        isNavigating: true,
      );

      return _currentNavigation;
    } catch (e) {
      // Fallback to simple route if routing service fails
      final currentLocation = await _locationService.getCurrentLocation();
      final destinationLatLng = LatLng(destination.latitude!, destination.longitude!);
      
      final route = _calculateSimpleRoute(currentLocation, destinationLatLng);
      final distance = _calculateDistance(currentLocation, destinationLatLng);
      final estimatedTime = _calculateEstimatedTime(distance);

      _currentNavigation = NavigationData(
        destination: destinationLatLng,
        route: route,
        totalDistance: distance,
        estimatedTime: estimatedTime,
        currentInstruction: 'Head towards ${destination.mainText}',
        distanceToNextTurn: distance,
        status: NavigationStatus.navigating,
      );

      _navigationController.add(_currentNavigation);
      _startNavigationUpdates();

      // Send initial instruction to helmet with complete data
      await _helmetService.sendNavigationDataComplete(
        instruction: _currentNavigation.currentInstruction,
        distanceToNextTurn: _currentNavigation.distanceToNextTurn,
        totalDistance: _currentNavigation.totalDistance,
        estimatedTimeMinutes: _currentNavigation.estimatedTime.inMinutes,
        status: 'navigating',
        isNavigating: true,
      );

      return _currentNavigation;
    }
  }

  void _startNavigationUpdates() {
    _navigationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_currentNavigation.status != NavigationStatus.navigating) {
        timer.cancel();
        return;
      }

      final currentLocation = await _locationService.getCurrentLocation();
      final updatedNavigation = _updateNavigationProgress(currentLocation);
      
      _currentNavigation = updatedNavigation;
      _navigationController.add(_currentNavigation);

      // Send updated complete navigation data to helmet
      await _helmetService.sendNavigationDataComplete(
        instruction: _currentNavigation.currentInstruction,
        distanceToNextTurn: _currentNavigation.distanceToNextTurn,
        totalDistance: _currentNavigation.totalDistance,
        estimatedTimeMinutes: _currentNavigation.estimatedTime.inMinutes,
        status: _currentNavigation.status.name,
        isNavigating: _currentNavigation.status == NavigationStatus.navigating,
      );
    });
  }

  NavigationData _updateNavigationProgress(LatLng currentLocation) {
    if (_currentNavigation.destination == null) {
      return _currentNavigation;
    }

    final distanceToDestination = _calculateDistance(currentLocation, _currentNavigation.destination!);
    
    // Check if arrived (within 50 meters)
    if (distanceToDestination < 0.05) {
      return NavigationData(
        destination: _currentNavigation.destination,
        route: _currentNavigation.route,
        totalDistance: _currentNavigation.totalDistance,
        estimatedTime: Duration.zero,
        currentInstruction: 'You have arrived at your destination',
        distanceToNextTurn: 0.0,
        status: NavigationStatus.arrived,
      );
    }

    // Update instruction based on route progress
    _updateInstructionIndex(currentLocation);
    
    final instruction = _getCurrentInstruction();
    final distanceToNextTurn = _getDistanceToNextTurn(currentLocation);
    final remainingTime = _calculateRemainingTime(currentLocation);

    return NavigationData(
      destination: _currentNavigation.destination,
      route: _currentNavigation.route,
      totalDistance: _currentNavigation.totalDistance,
      estimatedTime: remainingTime,
      currentInstruction: instruction,
      distanceToNextTurn: distanceToNextTurn,
      status: NavigationStatus.navigating,
    );
  }

  void _updateInstructionIndex(LatLng currentLocation) {
    if (_currentRoute == null || _currentRoute!.instructions.isEmpty) return;

    // Find the closest instruction based on current location
    // This is a simplified approach - in a real app you'd use more sophisticated logic
    final totalInstructions = _currentRoute!.instructions.length;
    final progressRatio = 1.0 - (_calculateDistance(currentLocation, _currentNavigation.destination!) / _currentNavigation.totalDistance);
    
    _currentInstructionIndex = (progressRatio * totalInstructions).floor().clamp(0, totalInstructions - 1);
  }

  String _getCurrentInstruction() {
    if (_currentRoute == null || _currentRoute!.instructions.isEmpty) {
      return 'Continue straight';
    }

    if (_currentInstructionIndex < _currentRoute!.instructions.length) {
      return _currentRoute!.instructions[_currentInstructionIndex].instruction;
    }

    return 'Continue to destination';
  }

  double _getDistanceToNextTurn(LatLng currentLocation) {
    if (_currentRoute == null || _currentRoute!.instructions.isEmpty) {
      return _calculateDistance(currentLocation, _currentNavigation.destination!);
    }

    if (_currentInstructionIndex < _currentRoute!.instructions.length) {
      return _currentRoute!.instructions[_currentInstructionIndex].distance / 1000; // Convert to km
    }

    return _calculateDistance(currentLocation, _currentNavigation.destination!);
  }

  Duration _calculateRemainingTime(LatLng currentLocation) {
    if (_currentRoute == null) {
      final remainingDistance = _calculateDistance(currentLocation, _currentNavigation.destination!);
      return _calculateEstimatedTime(remainingDistance);
    }

    // Calculate remaining time based on remaining instructions
    Duration remainingTime = Duration.zero;
    for (int i = _currentInstructionIndex; i < _currentRoute!.instructions.length; i++) {
      remainingTime += _currentRoute!.instructions[i].duration;
    }

    return remainingTime;
  }

  List<LatLng> _calculateSimpleRoute(LatLng start, LatLng end) {
    // Simplified route calculation - in real app would use routing service
    return [
      start,
      LatLng((start.latitude + end.latitude) / 2, (start.longitude + end.longitude) / 2),
      end,
    ];
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double lat1Rad = start.latitude * pi / 180;
    final double lat2Rad = end.latitude * pi / 180;
    final double deltaLatRad = (end.latitude - start.latitude) * pi / 180;
    final double deltaLngRad = (end.longitude - start.longitude) * pi / 180;

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  Duration _calculateEstimatedTime(double distanceKm) {
    // Assume average speed of 30 km/h for city riding
    const double averageSpeed = 30.0;
    final double timeHours = distanceKm / averageSpeed;
    return Duration(minutes: (timeHours * 60).round());
  }

  void stopNavigation() {
    _navigationTimer?.cancel();
    _currentRoute = null;
    _currentInstructionIndex = 0;
    _currentNavigation = NavigationData.empty();
    _navigationController.add(_currentNavigation);
  }

  void dispose() {
    _navigationTimer?.cancel();
    _navigationController.close();
  }
}