import 'dart:convert';

import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttStreamService {
  late final MqttServerClient _client;
  bool _connected = false;

  MqttStreamService() {
    _client = MqttServerClient('broker.example.com', 'lifepath_flutter');
    _client.port = 1883;
    _client.keepAlivePeriod = 20;
    _client.logging(on: false);
    _client.onConnected = () => _connected = true;
    _client.onDisconnected = () => _connected = false;
  }

  Future<void> connect() async {
    if (_connected) {
      return;
    }

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('lifepath_flutter')
        .withWillTopic('lifepath/status')
        .withWillMessage('offline')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _client.connectionMessage = connMessage;
    await _client.connect();
  }

  void publishLocation(LocationData location) {
    if (!_connected) {
      return;
    }

    final payload = jsonEncode({
      'lat': location.latitude,
      'lon': location.longitude,
      'speed': location.speed,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    _client.publishMessage(
      'lifepath/ambulance/location',
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }

  Future<void> disconnect() async {
    _client.disconnect();
  }

  void dispose() {}
}
