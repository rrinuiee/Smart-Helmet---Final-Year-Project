import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:io';
import '../models/helmet_data.dart';

class HelmetService {
  static final HelmetService _instance = HelmetService._internal();
  factory HelmetService() => _instance;
  HelmetService._internal();

  final StreamController<HelmetData> _dataController = StreamController<HelmetData>.broadcast();
  Stream<HelmetData> get dataStream => _dataController.stream;

  bool _isConnected = false;
  Timer? _mockDataTimer;
  HelmetData _currentData = HelmetData.disconnected();
  
  // ESP32 WebSocket connection
  WebSocket? _esp32Socket;
  String _esp32IpAddress = '192.168.1.100'; // Default IP, should be configurable

  bool get isConnected => _isConnected;
  HelmetData get currentData => _currentData;

  Future<bool> connectToHelmet() async {
    // Try to connect to ESP32 first
    await _connectToESP32();
    
    // Simulate connection process
    await Future.delayed(const Duration(seconds: 2));
    
    _isConnected = true;
    _startMockDataStream();
    
    return true;
  }

  Future<void> _connectToESP32() async {
    try {
      _esp32Socket = await WebSocket.connect('ws://$_esp32IpAddress:81');
      print('Connected to ESP32 at $_esp32IpAddress');
      
      _esp32Socket!.listen(
        (data) {
          print('Received from ESP32: $data');
        },
        onError: (error) {
          print('ESP32 WebSocket error: $error');
          _esp32Socket = null;
        },
        onDone: () {
          print('ESP32 WebSocket connection closed');
          _esp32Socket = null;
        },
      );
    } catch (e) {
      print('Failed to connect to ESP32: $e');
      _esp32Socket = null;
    }
  }

  void setESP32IpAddress(String ipAddress) {
    _esp32IpAddress = ipAddress;
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _mockDataTimer?.cancel();
    
    // Close ESP32 connection
    if (_esp32Socket != null) {
      await _esp32Socket!.close();
      _esp32Socket = null;
    }
    
    _currentData = HelmetData.disconnected();
    _dataController.add(_currentData);
  }

  void _startMockDataStream() {
    _mockDataTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }

      _currentData = _generateMockData();
      _dataController.add(_currentData);
    });
  }

  HelmetData _generateMockData() {
    final random = Random();
    
    // Simulate varying speed (0-60 km/h)
    final speed = 20 + random.nextDouble() * 40;
    
    // Simulate battery drain
    final battery = 100 - (DateTime.now().millisecondsSinceEpoch % 100000) / 1000;
    
    // Simulate safety status based on speed
    HelmetSafetyStatus safetyStatus;
    if (speed > 50) {
      safetyStatus = HelmetSafetyStatus.warning;
    } else if (speed > 70) {
      safetyStatus = HelmetSafetyStatus.danger;
    } else {
      safetyStatus = HelmetSafetyStatus.safe;
    }

    // Simulate sensor data
    final sensors = SensorData(
      drowsinessDetected: random.nextDouble() < 0.05, // 5% chance
      accidentDetected: false,
      accelerometerX: (random.nextDouble() - 0.5) * 2,
      accelerometerY: (random.nextDouble() - 0.5) * 2,
      accelerometerZ: 9.8 + (random.nextDouble() - 0.5),
      temperature: 25 + random.nextDouble() * 10,
      humidity: 50 + random.nextDouble() * 30,
    );

    return HelmetData(
      isConnected: true,
      speed: speed,
      batteryLevel: battery.clamp(0, 100),
      safetyStatus: safetyStatus,
      sensors: sensors,
      lastUpdate: DateTime.now(),
    );
  }

  Future<void> sendNavigationData(String instruction) async {
    // Send navigation data to ESP32 display
    if (_esp32Socket != null) {
      try {
        final navigationData = {
          'instruction': instruction,
          'distanceToNextTurn': 0.5, // This should come from NavigationService
          'totalDistance': 10.2, // This should come from NavigationService  
          'estimatedTimeMinutes': 15, // This should come from NavigationService
          'status': 'navigating',
          'isNavigating': true,
        };
        
        final jsonData = jsonEncode(navigationData);
        _esp32Socket!.add(jsonData);
        print('Sent to ESP32: $jsonData');
      } catch (e) {
        print('Failed to send data to ESP32: $e');
      }
    } else {
      print('ESP32 not connected. Navigation instruction: $instruction');
    }
    
    // Simulate sending navigation data to helmet HUD
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> sendNavigationDataComplete({
    required String instruction,
    required double distanceToNextTurn,
    required double totalDistance,
    required int estimatedTimeMinutes,
    required String status,
    required bool isNavigating,
  }) async {
    // Send complete navigation data to ESP32 display
    if (_esp32Socket != null) {
      try {
        final navigationData = {
          'instruction': instruction,
          'distanceToNextTurn': distanceToNextTurn,
          'totalDistance': totalDistance,
          'estimatedTimeMinutes': estimatedTimeMinutes,
          'status': status,
          'isNavigating': isNavigating,
        };
        
        final jsonData = jsonEncode(navigationData);
        _esp32Socket!.add(jsonData);
        print('Sent complete navigation data to ESP32: $jsonData');
      } catch (e) {
        print('Failed to send navigation data to ESP32: $e');
      }
    } else {
      print('ESP32 not connected. Navigation data: $instruction');
    }
  }

  void dispose() {
    _mockDataTimer?.cancel();
    _esp32Socket?.close();
    _dataController.close();
  }
}