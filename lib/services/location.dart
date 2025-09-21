import 'package:geolocator/geolocator.dart';

class Location {
  double? latitude;
  double? longitude;

  Future <void> getCurrentLocation() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.low,
      distanceFilter: 100,
    );
    bool serviceEnabled;
    LocationPermission permission;
    try {
      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location services are disabled.");
        return null;
      }

      // Check permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location permissions are denied");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Location permissions are permanently denied.");
        return null;
      }

      // ✅ If we get here → permission granted
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
      latitude = position.latitude;
      longitude = position.longitude;
    }
    catch (e) {
      print(e);
    }
  }
}

