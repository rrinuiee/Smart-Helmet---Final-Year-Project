import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';

class SimpleNavigationTest extends StatefulWidget {
  const SimpleNavigationTest({super.key});

  @override
  State<SimpleNavigationTest> createState() => _SimpleNavigationTestState();
}

class _SimpleNavigationTestState extends State<SimpleNavigationTest> {
  final MapController mapController = MapController();
  final LocationService _locationService = LocationService();
  
  LatLng _currentLocation = LocationService.defaultLocation;
  bool _isLoading = true;
  String _statusMessage = "Loading...";

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      setState(() {
        _statusMessage = "Getting location...";
      });
      
      final location = await _locationService.getCurrentLocation();
      
      if (mounted) {
        setState(() {
          _currentLocation = location;
          _isLoading = false;
          _statusMessage = "Location found: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}";
        });
        
        mapController.move(_currentLocation, 15.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = "Location error: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Test'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _isLoading ? Colors.orange[100] : Colors.green[100],
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _isLoading ? Colors.orange[800] : Colors.green[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Map
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading map and location...'),
                      ],
                    ),
                  )
                : FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation,
                      initialZoom: 15.0,
                      onTap: (tapPosition, point) {
                        print('Map tapped at: ${point.latitude}, ${point.longitude}');
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.smart_helmet_app',
                        maxZoom: 19,
                      ),
                      
                      MarkerLayer(
                        markers: [
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
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.my_location,
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
          
          // Test buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _initializeLocation,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          mapController.move(_currentLocation, 15.0);
                        },
                        icon: const Icon(Icons.center_focus_strong),
                        label: const Text('Center Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Test internet connectivity
                      try {
                        setState(() {
                          _statusMessage = "Testing internet connection...";
                        });
                        
                        final response = await _locationService.getCurrentLocation();
                        setState(() {
                          _statusMessage = "Internet test successful! Location: ${response.latitude.toStringAsFixed(4)}, ${response.longitude.toStringAsFixed(4)}";
                        });
                      } catch (e) {
                        setState(() {
                          _statusMessage = "Internet test failed: $e";
                        });
                      }
                    },
                    icon: const Icon(Icons.wifi),
                    label: const Text('Test Internet Connection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}