import 'package:flutter/material.dart';
import '../models/helmet_data.dart';
import '../services/helmet_service.dart';
import '../services/emergency_service.dart';

class SafetyMonitoringScreen extends StatefulWidget {
  const SafetyMonitoringScreen({super.key});

  @override
  State<SafetyMonitoringScreen> createState() => _SafetyMonitoringScreenState();
}

class _SafetyMonitoringScreenState extends State<SafetyMonitoringScreen> {
  final HelmetService _helmetService = HelmetService();
  final EmergencyService _emergencyService = EmergencyService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Monitoring'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<HelmetData>(
        stream: _helmetService.dataStream,
        initialData: _helmetService.currentData,
        builder: (context, snapshot) {
          final helmetData = snapshot.data ?? HelmetData.disconnected();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Safety Status
                _buildOverallSafetyCard(helmetData),
                
                const SizedBox(height: 24),
                
                // Sensor Monitoring Section
                const Text(
                  'Sensor Monitoring',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildSensorCard(
                  'Drowsiness Detection',
                  helmetData.sensors.drowsinessDetected,
                  Icons.visibility_off,
                  'Driver alertness monitoring',
                ),
                
                const SizedBox(height: 12),
                
                _buildSensorCard(
                  'Accident Detection',
                  helmetData.sensors.accidentDetected,
                  Icons.warning,
                  'Impact and crash detection',
                ),
                
                const SizedBox(height: 24),
                
                // Environmental Data Section
                const Text(
                  'Environmental Data',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildEnvironmentalCard(
                        'Temperature',
                        '${helmetData.sensors.temperature.toStringAsFixed(1)}°C',
                        Icons.thermostat,
                        _getTemperatureColor(helmetData.sensors.temperature),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEnvironmentalCard(
                        'Humidity',
                        '${helmetData.sensors.humidity.toStringAsFixed(1)}%',
                        Icons.water_drop,
                        _getHumidityColor(helmetData.sensors.humidity),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Accelerometer Data Section
                const Text(
                  'Motion Sensors',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildAccelerometerCard(helmetData.sensors),
                
                const SizedBox(height: 24),
                
                // Emergency Actions
                const Text(
                  'Emergency Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _testEmergencyAlert();
                        },
                        icon: const Icon(Icons.warning),
                        label: const Text('Test Alert'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _triggerSOS();
                        },
                        icon: const Icon(Icons.emergency),
                        label: const Text('SOS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallSafetyCard(HelmetData helmetData) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;

    switch (helmetData.safetyStatus) {
      case HelmetSafetyStatus.safe:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'SAFE';
        statusDescription = 'All systems normal';
        break;
      case HelmetSafetyStatus.warning:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'WARNING';
        statusDescription = 'Caution advised';
        break;
      case HelmetSafetyStatus.danger:
        statusColor = Colors.red;
        statusIcon = Icons.dangerous;
        statusText = 'DANGER';
        statusDescription = 'Immediate attention required';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'UNKNOWN';
        statusDescription = 'Status unavailable';
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [statusColor.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    statusDescription,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(String title, bool isActive, IconData icon, String description) {
    final color = isActive ? Colors.red : Colors.green;
    final status = isActive ? 'ACTIVE' : 'NORMAL';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnvironmentalCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccelerometerCard(SensorData sensors) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Accelerometer Data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAccelValue('X', sensors.accelerometerX),
                _buildAccelValue('Y', sensors.accelerometerY),
                _buildAccelValue('Z', sensors.accelerometerZ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccelValue(String axis, double value) {
    return Column(
      children: [
        Text(
          axis,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature < 10) return Colors.blue;
    if (temperature < 25) return Colors.green;
    if (temperature < 35) return Colors.orange;
    return Colors.red;
  }

  Color _getHumidityColor(double humidity) {
    if (humidity < 30) return Colors.orange;
    if (humidity < 70) return Colors.green;
    return Colors.blue;
  }

  Future<void> _testEmergencyAlert() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚨 Test alert sent to emergency contacts'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _triggerSOS() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Emergency SOS'),
          ],
        ),
        content: const Text(
          'This will send your location to emergency contacts and services. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _emergencyService.triggerSOS();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🚨 Emergency SOS sent successfully'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send SOS: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}