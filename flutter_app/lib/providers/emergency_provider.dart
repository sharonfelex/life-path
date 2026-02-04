import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/location_stream_service.dart';
import '../services/mqtt_stream_service.dart';

class EmergencyProvider extends ChangeNotifier {
  final LocationStreamService _locationService = LocationStreamService();
  final MqttStreamService _mqttService = MqttStreamService();

  bool _isEmergencyActive = false;
  Timer? _heartbeat;

  bool get isEmergencyActive => _isEmergencyActive;

  Future<void> toggleEmergency() async {
    _isEmergencyActive = !_isEmergencyActive;

    if (_isEmergencyActive) {
      await _mqttService.connect();
      await _locationService.start();
      _heartbeat = Timer.periodic(const Duration(seconds: 2), (_) async {
        final position = await _locationService.fetchLocation();
        if (position != null) {
          _mqttService.publishLocation(position);
        }
      });
    } else {
      _heartbeat?.cancel();
      await _locationService.stop();
      await _mqttService.disconnect();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _heartbeat?.cancel();
    _locationService.dispose();
    _mqttService.dispose();
    super.dispose();
  }
}
