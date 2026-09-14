import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key, this.initialLatitude, this.initialLongitude});

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const _defaultCenter = LatLng(32.4279, 53.6880);
  late final MapController _mapController;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
  }

  void _selectLocation(LatLng point) {
    setState(() => _selectedLocation = point);
  }

  @override
  Widget build(BuildContext context) {
    final center = _selectedLocation ?? _defaultCenter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('انتخاب موقعیت روی نقشه'),
        actions: [
          IconButton(
            tooltip: 'بازگشت به مرکز ایران',
            onPressed: () => _mapController.move(_defaultCenter, 5.2),
            icon: const Icon(Icons.center_focus_strong),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: _selectedLocation == null ? 5.2 : 15,
              onTap: (_, point) => _selectLocation(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.frontend',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.location_pin, size: 50, color: Colors.red),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _selectedLocation == null
                      ? 'روی نقشه روی محل دقیق تحویل ضربه بزنید.'
                      : 'موقعیت انتخاب شد. اگر لازم است نقطه را جابه‌جا کنید.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: FilledButton.icon(
              onPressed: _selectedLocation == null
                  ? null
                  : () => Navigator.of(context).pop((
                        latitude: _selectedLocation!.latitude,
                        longitude: _selectedLocation!.longitude,
                      )),
              icon: const Icon(Icons.check),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('تأیید موقعیت'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
