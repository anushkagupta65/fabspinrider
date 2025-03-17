import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/order.dart';

class MyMapPage {
  final PickupDrop order;

  MyMapPage({required this.order});

  Future<void> _getCurrentLocationAndOpenMap() async {
    try {
      Position position = await _getCurrentLocation();
      String destinationAddress = order.pickupAddress;
      await _openGoogleMaps(position, destinationAddress);
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _openGoogleMaps(
      Position currentPosition, String destinationAddress) async {
    final origin = '${currentPosition.latitude},${currentPosition.longitude}';
    final destination = Uri.encodeComponent(destinationAddress);
    final Uri googleUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving');

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map for navigation.';
    }
  }

  void navigateToDestination() {
    _getCurrentLocationAndOpenMap();
  }
}

void startNavigation(PickupDrop order) {
  MyMapPage(order: order).navigateToDestination();
}
