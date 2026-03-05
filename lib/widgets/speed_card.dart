import 'package:flutter/material.dart';

class SpeedCard extends StatelessWidget {
  final double speed;

  const SpeedCard({
    super.key,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.speed,
              color: _getSpeedColor(speed),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              speed.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _getSpeedColor(speed),
              ),
            ),
            const Text(
              'km/h',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getSpeedColor(speed).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getSpeedStatus(speed),
                style: TextStyle(
                  color: _getSpeedColor(speed),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSpeedColor(double speed) {
    if (speed == 0) return Colors.grey;
    if (speed <= 30) return Colors.green;
    if (speed <= 50) return Colors.orange;
    return Colors.red;
  }

  String _getSpeedStatus(double speed) {
    if (speed == 0) return 'STOPPED';
    if (speed <= 30) return 'SAFE';
    if (speed <= 50) return 'MODERATE';
    return 'HIGH SPEED';
  }
}