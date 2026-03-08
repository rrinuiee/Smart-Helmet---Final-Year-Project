import 'package:flutter/material.dart';
import '../services/helmet_service.dart';

class HelmetSettingsScreen extends StatefulWidget {
  const HelmetSettingsScreen({super.key});

  @override
  State<HelmetSettingsScreen> createState() => _HelmetSettingsScreenState();
}

class _HelmetSettingsScreenState extends State<HelmetSettingsScreen> {
  final TextEditingController _ipController = TextEditingController();
  final HelmetService _helmetService = HelmetService();
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    // Set default IP
    _ipController.text = '192.168.1.100';
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _connectToESP32() async {
    if (_ipController.text.isEmpty) {
      _showMessage('Please enter ESP32 IP address', isError: true);
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      _helmetService.setESP32IpAddress(_ipController.text);
      await _helmetService.connectToHelmet();
      
      if (mounted) {
        _showMessage('Connected to ESP32 successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to connect: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _testConnection() async {
    try {
      await _helmetService.sendNavigationDataComplete(
        instruction: 'Test navigation instruction',
        distanceToNextTurn: 0.5,
        totalDistance: 10.2,
        estimatedTimeMinutes: 15,
        status: 'navigating',
        isNavigating: true,
      );
      
      if (mounted) {
        _showMessage('Test data sent to ESP32!');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to send test data: $e', isError: true);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Helmet Display Settings'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.display_settings, 
                             color: Colors.blue[600], size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'ESP32 Display Connection',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    const Text(
                      'ESP32 IP Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ipController,
                      decoration: InputDecoration(
                        hintText: '192.168.1.100',
                        prefixIcon: const Icon(Icons.wifi),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isConnecting ? null : _connectToESP32,
                            icon: _isConnecting 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.link),
                            label: Text(_isConnecting ? 'Connecting...' : 'Connect'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _helmetService.isConnected ? _testConnection : null,
                          icon: const Icon(Icons.send),
                          label: const Text('Test'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, 
                             color: Colors.orange[600], size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Setup Instructions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    const Text(
                      '1. Upload the Arduino code to your ESP32',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '2. Connect the ST7789 display to ESP32',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '3. Power on ESP32 and note the IP address on display',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '4. Enter the IP address above and click Connect',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '5. Start navigation to see data on ESP32 display',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            StreamBuilder<bool>(
              stream: Stream.periodic(const Duration(seconds: 1))
                  .map((_) => _helmetService.isConnected),
              builder: (context, snapshot) {
                final isConnected = snapshot.data ?? false;
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isConnected ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isConnected ? 'Connected to ESP32' : 'Not Connected',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isConnected ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}