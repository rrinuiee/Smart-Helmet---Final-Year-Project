import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/helmet_data.dart';
import '../services/helmet_service.dart';
import '../services/emergency_service.dart';
import '../widgets/helmet_status_card.dart';
import '../widgets/speed_card.dart';
import '../widgets/safety_status_card.dart';
import '../widgets/quick_action_buttons.dart';
import 'navigation_screen.dart';
import 'safety_monitoring_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HelmetService _helmetService = HelmetService();
  final EmergencyService _emergencyService = EmergencyService();

  @override
  void initState() {
    super.initState();
    _connectToHelmet();
  }

  Future<void> _connectToHelmet() async {
    await _helmetService.connectToHelmet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Smart Helmet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: StreamBuilder<HelmetData>(
        stream: _helmetService.dataStream,
        initialData: _helmetService.currentData,
        builder: (context, snapshot) {
          final helmetData = snapshot.data ?? HelmetData.disconnected();
          
          return RefreshIndicator(
            onRefresh: () async {
              await _connectToHelmet();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Helmet Status Section
                  const Text(
                    'Helmet Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  HelmetStatusCard(helmetData: helmetData),
                  
                  const SizedBox(height: 24),
                  
                  // Riding Data Section
                  const Text(
                    'Riding Data',
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
                        child: SpeedCard(speed: helmetData.speed),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SafetyStatusCard(status: helmetData.safetyStatus),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions Section
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  QuickActionButtons(
                    onNavigationPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NavigationScreen(),
                        ),
                      );
                    },
                    onSafetyPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SafetyMonitoringScreen(),
                        ),
                      );
                    },
                    onSOSPressed: () async {
                      await _showSOSDialog();
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Emergency SOS Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _showSOSDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emergency, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'EMERGENCY SOS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showSOSDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
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