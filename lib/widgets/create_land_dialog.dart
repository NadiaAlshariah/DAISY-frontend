import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class CreateLandDialog extends StatefulWidget {
  final String? initialName;
  final double? initialLatitude;
  final double? initialLongitude;
  final String title;
  final String confirmText;

  const CreateLandDialog({
    super.key,
    this.initialName,
    this.initialLatitude,
    this.initialLongitude,
    this.title = 'Create New Land',
    this.confirmText = 'Create',
  });

  @override
  State<CreateLandDialog> createState() => _CreateLandDialogState();
}

class _CreateLandDialogState extends State<CreateLandDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _latController;
  late TextEditingController _lonController;
  LatLng? _selectedPosition;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _latController = TextEditingController(
      text: widget.initialLatitude?.toString() ?? '',
    );
    _lonController = TextEditingController(
      text: widget.initialLongitude?.toString() ?? '',
    );

    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedPosition = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
    }

    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    try {
      final position = await Geolocator.getCurrentPosition();
      final LatLng userLocation = LatLng(position.latitude, position.longitude);

      if (widget.initialLatitude == null || widget.initialLongitude == null) {
        setState(() {
          _selectedPosition = userLocation;
          _latController.text = userLocation.latitude.toString();
          _lonController.text = userLocation.longitude.toString();
        });
        _mapController.move(userLocation, 13);
      }
    } catch (e) {
      throw Exception("Failed to get location: $e");
    }
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _selectedPosition = point;
      _latController.text = point.latitude.toString();
      _lonController.text = point.longitude.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 320,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Land Name"),
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(onTap: (_, point) => _onMapTap(point)),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.daisy.myapp',
                      ),
                      if (_selectedPosition != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 40,
                              height: 40,
                              point: _selectedPosition!,
                              child: const Icon(
                                Icons.location_on,
                                size: 40,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: const Text("Go to My Location"),
                  onPressed: () async {
                    try {
                      final pos = await Geolocator.getCurrentPosition();
                      final userLocation = LatLng(pos.latitude, pos.longitude);
                      _mapController.move(userLocation, 13);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to get location: $e")),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Latitude: ${_latController.text}"),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Longitude: ${_lonController.text}"),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final data = {
                'name': _nameController.text.trim(),
                'latitude': double.parse(_latController.text),
                'longitude': double.parse(_lonController.text),
              };
              Navigator.pop(context, data);
            }
          },
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}
