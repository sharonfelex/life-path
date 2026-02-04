import 'package:location/location.dart';

class LocationStreamService {
  final Location _location = Location();
  bool _initialized = false;

  Future<void> start() async {
    if (_initialized) {
      return;
    }

    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _initialized = true;
  }

  Future<LocationData?> fetchLocation() async {
    if (!_initialized) {
      return null;
    }

    return _location.getLocation();
  }

  Future<void> stop() async {
    _initialized = false;
  }

  void dispose() {}
}
