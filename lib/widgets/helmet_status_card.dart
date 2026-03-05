import 'package:flutter/material.dart';
import '../models/helmet_data.dart';

class HelmetStatusCard extends StatelessWidget {
  final HelmetData helmetData;

  const HelmetStatusCard({
    super.key,
    required this.helmetData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: helmetData.isConnected
                ? [Colors.green.withOpacity(0.1), Colors.white]
                : [Colors.red.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: helmetData.isConnected
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    helmetData.isConnected
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                    color: helmetData.isConnected ? Colors.green : Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        helmetData.isConnected ? 'CONNECTED' : 'DISCONNECTED',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: helmetData.isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        helmetData.isConnected
                            ? 'Smart Helmet Online'
                            : 'Helmet Not Connected',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (helmetData.isConnected)
                  Column(
                    children: [
                      Icon(
                        Icons.battery_std,
                        color: _getBatteryColor(helmetData.batteryLevel),
                        size: 24,
                      ),
                      Text(
                        '${helmetData.batteryLevel.toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getBatteryColor(helmetData.batteryLevel),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            
            if (helmetData.isConnected) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatusItem(
                    'GPS',
                    Icons.gps_fixed,
                    Colors.green,
                    'Active',
                  ),
                  _buildStatusItem(
                    'Sensors',
                    Icons.sensors,
                    Colors.blue,
                    'Online',
                  ),
                  _buildStatusItem(
                    'Camera',
                    Icons.camera_alt,
                    Colors.orange,
                    'Ready',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, IconData icon, Color color, String status) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getBatteryColor(double batteryLevel) {
    if (batteryLevel > 50) return Colors.green;
    if (batteryLevel > 20) return Colors.orange;
    return Colors.red;
  }
}