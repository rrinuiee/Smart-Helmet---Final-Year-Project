class HelmetData {
  final bool isConnected;
  final double speed;
  final double batteryLevel;
  final HelmetSafetyStatus safetyStatus;
  final SensorData sensors;
  final DateTime lastUpdate;

  HelmetData({
    required this.isConnected,
    required this.speed,
    required this.batteryLevel,
    required this.safetyStatus,
    required this.sensors,
    required this.lastUpdate,
  });

  factory HelmetData.disconnected() {
    return HelmetData(
      isConnected: false,
      speed: 0.0,
      batteryLevel: 0.0,
      safetyStatus: HelmetSafetyStatus.unknown,
      sensors: SensorData.empty(),
      lastUpdate: DateTime.now(),
    );
  }

  factory HelmetData.mockData() {
    return HelmetData(
      isConnected: true,
      speed: 45.5,
      batteryLevel: 78.0,
      safetyStatus: HelmetSafetyStatus.safe,
      sensors: SensorData.mockData(),
      lastUpdate: DateTime.now(),
    );
  }
}

enum HelmetSafetyStatus {
  safe,
  warning,
  danger,
  unknown,
}

class SensorData {
  final bool drowsinessDetected;
  final bool accidentDetected;
  final double accelerometerX;
  final double accelerometerY;
  final double accelerometerZ;
  final double temperature;
  final double humidity;

  SensorData({
    required this.drowsinessDetected,
    required this.accidentDetected,
    required this.accelerometerX,
    required this.accelerometerY,
    required this.accelerometerZ,
    required this.temperature,
    required this.humidity,
  });

  factory SensorData.empty() {
    return SensorData(
      drowsinessDetected: false,
      accidentDetected: false,
      accelerometerX: 0.0,
      accelerometerY: 0.0,
      accelerometerZ: 0.0,
      temperature: 0.0,
      humidity: 0.0,
    );
  }

  factory SensorData.mockData() {
    return SensorData(
      drowsinessDetected: false,
      accidentDetected: false,
      accelerometerX: 0.2,
      accelerometerY: 0.1,
      accelerometerZ: 9.8,
      temperature: 28.5,
      humidity: 65.0,
    );
  }
}