import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

import '../model/order.dart';  // Assuming you're using GetX for navigation

class MyMapPage {
  final PickupDrop order; // Declare the order variable

  MyMapPage({required this.order});

  Future<void> _getCurrentLocationAndOpenMap() async {
    try {
      Position position = await _getCurrentLocation();
      String destinationAddress = order.pickupAddress; // The destination address from your order
      await _openGoogleMaps(position, destinationAddress);
    } catch (e) {
      print(e);
      // Handle error (e.g., show a message to the user)
    }
  }

  // Function to get the current location
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return Future.error('Location permissions are denied');
      }
    }

    // Get the current position
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // Function to open Google Maps with navigation
  Future<void> _openGoogleMaps(Position currentPosition, String destinationAddress) async {
    final origin = '${currentPosition.latitude},${currentPosition.longitude}';
    final destination = Uri.encodeComponent(destinationAddress);
    final googleUrl = 'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving';

    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map for navigation.';
    }
  }

  // Call this method to initiate the navigation
  void navigateToDestination() {
    _getCurrentLocationAndOpenMap();
  }
}

// Use this to trigger navigation
void startNavigation(PickupDrop order) {
  MyMapPage(order: order).navigateToDestination();
}
