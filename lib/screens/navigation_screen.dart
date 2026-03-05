import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/place_prediction.dart';
import '../models/navigation_data.dart';
import '../services/places_service.dart';
import '../services/location_service.dart';
import '../services/navigation_service.dart';
import '../utils/debouncer.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final MapController mapController = MapController();
  final TextEditingController _destinationController = TextEditingController();
  
  final PlacesService _placesService = PlacesService();
  final LocationService _locationService = LocationService();
  final NavigationService _navigationService = NavigationService();
  final Debouncer _searchDebouncer = Debouncer();

  LatLng _currentLocation = LocationService.defaultLocation;
  NavigationData _navigationData = NavigationData.empty();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _listenToNavigation();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentLocation = location;
        });
        mapController.move(_currentLocation, 15.0);
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _listenToNavigation() {
    _navigationService.navigationStream.listen((navigationData) {
      if (mounted) {
        setState(() {
          _navigationData = navigationData;
        });
        
        // Auto-fit camera when route is calculated
        if (navigationData.route.isNotEmpty && navigationData.status == NavigationStatus.navigating) {
          _fitCameraToRoute(navigationData.route);
        }
      }
    });
  }

  void _fitCameraToRoute(List<LatLng> route) {
    if (route.isEmpty) return;
    
    try {
      final bounds = LatLngBounds.fromPoints(route);
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds, 
          padding: const EdgeInsets.all(50),
        ),
      );
    } catch (e) {
      print('Error fitting camera to route: $e');
    }
  }

  Future<Iterable<PlacePrediction>> _getLocationSuggestions(String query) async {
    if (query.isEmpty || query.length < 3) {
      return const Iterable<PlacePrediction>.empty();
    }

    try {
      final predictions = await _placesService.getPlacePredictions(
        query,
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
      );
      return predictions;
    } catch (e) {
      print('Error getting predictions: $e');
      return const Iterable<PlacePrediction>.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (_navigationData.status == NavigationStatus.navigating)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () {
                _navigationService.stopNavigation();
                setState(() {
                  _navigationData = NavigationData.empty();
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Autocomplete<PlacePrediction>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    return await _getLocationSuggestions(textEditingValue.text);
                  },
                  onSelected: (PlacePrediction selection) async {
                    _destinationController.text = selection.mainText;
                    await _startNavigation(selection);
                  },
                  displayStringForOption: (PlacePrediction option) => 
                    '${option.mainText}, ${option.secondaryText}',
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'Search destination...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  controller.clear();
                                  _navigationService.stopNavigation();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    );
                  },
                ),
                
                // Navigation Info Card
                if (_navigationData.status != NavigationStatus.idle) ...[
                  const SizedBox(height: 16),
                  _buildNavigationInfoCard(),
                ],
              ],
            ),
          ),
          
          // Map Section
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.smart_helmet_app',
                ),
                
                // Route polyline
                if (_navigationData.route.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _navigationData.route,
                        strokeWidth: 5.0,
                        color: Colors.blue.shade600,
                        borderStrokeWidth: 2.0,
                        borderColor: Colors.white,
                      ),
                    ],
                  ),
                
                // Markers
                MarkerLayer(
                  markers: [
                    // Current location marker
                    Marker(
                      point: _currentLocation,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    
                    // Destination marker
                    if (_navigationData.destination != null)
                      Marker(
                        point: _navigationData.destination!,
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _initializeLocation,
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildNavigationInfoCard() {
    Color statusColor;
    IconData statusIcon;
    
    switch (_navigationData.status) {
      case NavigationStatus.calculating:
        statusColor = Colors.orange;
        statusIcon = Icons.route;
        break;
      case NavigationStatus.navigating:
        statusColor = Colors.green;
        statusIcon = Icons.navigation;
        break;
      case NavigationStatus.arrived:
        statusColor = Colors.blue;
        statusIcon = Icons.flag;
        break;
      case NavigationStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  if (_navigationData.status == NavigationStatus.calculating)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                ],
              ),
              
              if (_navigationData.status == NavigationStatus.navigating) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.turn_right, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _navigationData.currentInstruction,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoTile(
                        icon: Icons.straighten,
                        label: 'Distance',
                        value: '${_navigationData.totalDistance.toStringAsFixed(1)} km',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoTile(
                        icon: Icons.access_time,
                        label: 'ETA',
                        value: _formatDuration(_navigationData.estimatedTime),
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                if (_navigationData.distanceToNextTurn > 0) ...[
                  const SizedBox(height: 12),
                  _buildInfoTile(
                    icon: Icons.turn_slight_right,
                    label: 'Next Turn',
                    value: '${(_navigationData.distanceToNextTurn * 1000).toInt()} m',
                    color: Colors.orange,
                  ),
                ],
              ],
              
              if (_navigationData.status == NavigationStatus.arrived) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'You have arrived at your destination!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (_navigationData.status) {
      case NavigationStatus.calculating:
        return 'Calculating route...';
      case NavigationStatus.navigating:
        return 'Navigating';
      case NavigationStatus.arrived:
        return 'You have arrived!';
      case NavigationStatus.error:
        return 'Navigation error';
      default:
        return 'Ready';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Future<void> _startNavigation(PlacePrediction destination) async {
    try {
      await _navigationService.startNavigation(destination);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.navigation, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Navigation started'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to start navigation: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }
}