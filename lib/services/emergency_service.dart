import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'location_service.dart';

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  final LocationService _locationService = LocationService();
  
  final List<EmergencyContact> _emergencyContacts = [
    EmergencyContact(name: 'Emergency Services', phone: '112'),
    EmergencyContact(name: 'Police', phone: '100'),
    EmergencyContact(name: 'Ambulance', phone: '108'),
  ];

  List<EmergencyContact> get emergencyContacts => _emergencyContacts;

  Future<EmergencyAlert> triggerSOS() async {
    final location = await _locationService.getCurrentLocation();
    
    final alert = EmergencyAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      location: location,
      timestamp: DateTime.now(),
      type: EmergencyType.sos,
      message: 'SOS Alert triggered from Smart Helmet',
    );

    // Simulate sending alert to emergency contacts
    await _sendEmergencyAlert(alert);
    
    return alert;
  }

  Future<EmergencyAlert> triggerAccidentAlert(LatLng location) async {
    final alert = EmergencyAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      location: location,
      timestamp: DateTime.now(),
      type: EmergencyType.accident,
      message: 'Accident detected by Smart Helmet sensors',
    );

    await _sendEmergencyAlert(alert);
    
    return alert;
  }

  Future<void> _sendEmergencyAlert(EmergencyAlert alert) async {
    // Simulate sending SMS/call to emergency contacts
    print('🚨 EMERGENCY ALERT SENT 🚨');
    print('Type: ${alert.type}');
    print('Location: ${alert.location.latitude}, ${alert.location.longitude}');
    print('Time: ${alert.timestamp}');
    print('Message: ${alert.message}');
    
    // In real implementation, this would:
    // 1. Send SMS to emergency contacts
    // 2. Make emergency calls
    // 3. Send location to emergency services
    // 4. Trigger helmet alarm/lights
    
    await Future.delayed(const Duration(seconds: 1));
  }

  void addEmergencyContact(EmergencyContact contact) {
    _emergencyContacts.add(contact);
  }

  void removeEmergencyContact(String phone) {
    _emergencyContacts.removeWhere((contact) => contact.phone == phone);
  }
}

class EmergencyContact {
  final String name;
  final String phone;

  EmergencyContact({
    required this.name,
    required this.phone,
  });
}

class EmergencyAlert {
  final String id;
  final LatLng location;
  final DateTime timestamp;
  final EmergencyType type;
  final String message;

  EmergencyAlert({
    required this.id,
    required this.location,
    required this.timestamp,
    required this.type,
    required this.message,
  });
}

enum EmergencyType {
  sos,
  accident,
  drowsiness,
}