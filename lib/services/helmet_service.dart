import 'dart:async';
import 'dart:math';
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

  bool get isConnected => _isConnected;
  HelmetData get currentData => _currentData;

  Future<bool> connectToHelmet() async {
    // Simulate connection process
    await Future.delayed(const Duration(seconds: 2));
    
    _isConnected = true;
    _startMockDataStream();
    
    return true;
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _mockDataTimer?.cancel();
    
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
    // Simulate sending navigation data to helmet HUD
    print('Sending to helmet: $instruction');
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void dispose() {
    _mockDataTimer?.cancel();
    _dataController.close();
  }
}