import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin, sin, pi;

import '../models/mandi_model.dart';

class LocationService {
  /// Request permissions and get current position
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  /// Haversine formula to calculate distance between two coordinates in kilometers
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Sorts a list of mandis by distance from the user's current location.
  /// Modifies the returned list items to update their 'distance' string property.
  List<MandiModel> sortMandisByDistance(List<MandiModel> mandis, Position currentPosition) {
    // Create a mutable copy
    List<MandiModel> sorted = List.from(mandis);

    // Calculate distance and update the model (we'll recreate them to update the distance string)
    sorted = sorted.map((mandi) {
      // If coordinates are 0, it means we don't have them, push to bottom
      if (mandi.latitude == 0.0 && mandi.longitude == 0.0) {
        return mandi;
      }

      double dist = calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        mandi.latitude,
        mandi.longitude,
      );

      // Recreate the model with the updated distance string
      return MandiModel(
        id: mandi.id,
        name: mandi.name,
        city: mandi.city,
        province: mandi.province,
        distance: '${dist.toStringAsFixed(1)} km', // Update string format
        isOpen: mandi.isOpen,
        totalCrops: mandi.totalCrops,
        latitude: mandi.latitude,
        longitude: mandi.longitude,
      );
    }).toList();

    // Sort by numeric distance string
    sorted.sort((a, b) {
      // Parse '12.5 km' to 12.5
      double parseDist(String d) {
        try {
          return double.parse(d.replaceAll(' km', '').replaceAll('+', '').trim());
        } catch (_) {
          return 9999.0; // Fallback to bottom
        }
      }

      return parseDist(a.distance).compareTo(parseDist(b.distance));
    });

    return sorted;
  }
}
