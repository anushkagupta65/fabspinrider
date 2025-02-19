import 'dart:ui' as ui;

import 'package:fabspinrider/model/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../screen/widgets/order_card.dart';
import '../widgets/bottom_container.dart';

class MapScreen extends StatelessWidget {
  final PickupDrop order;
  static const String routeName = '/map-screen';

   MapScreen({super.key, required this.order});

  final LatLng latLng = LatLng(28.704060, 77.102493); // Fixed starting coordinates
  final LatLng destination = LatLng(29.602100, 77.363700); // Fixed destination coordinates
  final List<LatLng> polylineCoordinates = [
    LatLng(28.704060, 77.102493),
    LatLng(28.704060, 77.102493),
    LatLng(29.602100, 77.363700),
  ]; // Sample polyline

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: latLng,
                    zoom: 14.0,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('start'),
                      position: latLng,
                      icon: BitmapDescriptor.defaultMarker,
                    ),
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: destination,
                      icon: BitmapDescriptor.defaultMarker,
                    ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: polylineCoordinates,
                      color: Colors.blue,
                      width: 5,
                    ),
                  },
                ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: BottomContainer(
                    order: order,
                    pickUpHandler: () {}, // Static handler
                    deliverHandler: () {}, // Static handler
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_sharp),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
