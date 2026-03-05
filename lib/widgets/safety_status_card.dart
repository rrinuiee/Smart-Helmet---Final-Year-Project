import 'package:flutter/material.dart';
import '../models/helmet_data.dart';

class SafetyStatusCard extends StatelessWidget {
  final HelmetSafetyStatus status;

  const SafetyStatusCard({
    super.key,
    required this.status,
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
            colors: [_getStatusColor(status).withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _getStatusIcon(status),
              color: _getStatusColor(status),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusText(status),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(status),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Safety Status',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _getStatusLevel(status),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(HelmetSafetyStatus status) {
    switch (status) {
      case HelmetSafetyStatus.safe:
        return Colors.green;
      case HelmetSafetyStatus.warning:
        return Colors.orange;
      case HelmetSafetyStatus.danger:
        return Colors.red;
      case HelmetSafetyStatus.unknown:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(HelmetSafetyStatus status) {
    switch (status) {
      case HelmetSafetyStatus.safe:
        return Icons.check_circle;
      case HelmetSafetyStatus.warning:
        return Icons.warning;
      case HelmetSafetyStatus.danger:
        return Icons.dangerous;
      case HelmetSafetyStatus.unknown:
        return Icons.help;
    }
  }

  String _getStatusText(HelmetSafetyStatus status) {
    switch (status) {
      case HelmetSafetyStatus.safe:
        return 'SAFE';
      case HelmetSafetyStatus.warning:
        return 'WARNING';
      case HelmetSafetyStatus.danger:
        return 'DANGER';
      case HelmetSafetyStatus.unknown:
        return 'UNKNOWN';
    }
  }

  double _getStatusLevel(HelmetSafetyStatus status) {
    switch (status) {
      case HelmetSafetyStatus.safe:
        return 1.0;
      case HelmetSafetyStatus.warning:
        return 0.6;
      case HelmetSafetyStatus.danger:
        return 0.3;
      case HelmetSafetyStatus.unknown:
        return 0.0;
    }
  }
}