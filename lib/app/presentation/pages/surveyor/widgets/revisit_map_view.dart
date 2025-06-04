import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RevisitMapView extends StatelessWidget {
  final List<LatLng> coordinates;
  final double zoom;
  final bool drawLine;

  const RevisitMapView({
    super.key,
    required this.coordinates,
    this.zoom = 13.0,
    this.drawLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<Marker> markers = [];

    if (drawLine && coordinates.length >= 2) {
      // Mostrar marcador verde para inicio y azul para fin
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: coordinates.first,
          child: const Icon(Icons.location_on, color: Colors.green, size: 32),
        ),
      );
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: coordinates.last,
          child: const Icon(Icons.location_on, color: Colors.blue, size: 32),
        ),
      );
    } else {
      // Mostrar todos como puntos rojos
      markers.addAll(
        coordinates.map(
              (coord) => Marker(
            width: 40,
            height: 40,
            point: coord,
            child: const Icon(Icons.location_pin, color: Colors.red, size: 32),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          options: MapOptions(
            center: coordinates.first,
            zoom: zoom,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.example.app',
            ),
            if (drawLine && coordinates.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: coordinates,
                    strokeWidth: 4,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }
}
