import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? mapController;

  // Monas Jakarta coordinates
  final LatLng monasLocation = LatLng(-7.290130, 112.779206);

  void _onMapCreated(GoogleMapController controller) {
    if (!mounted) {
      controller.dispose();
      return;
    }
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: monasLocation,
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: MarkerId('monas'),
              position: monasLocation,
              infoWindow: InfoWindow(
                title: 'Monas Jakarta',
                snippet: 'National Monument',
              ),
            ),
          },
          mapType: MapType.normal,
        ),
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
