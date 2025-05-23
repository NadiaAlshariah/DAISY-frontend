import 'package:flutter/material.dart';
import 'package:daisy_frontend/services/lands_service.dart';
import 'package:daisy_frontend/widgets/create_land_dialog.dart';
import 'package:daisy_frontend/widgets/show_confirm_dialog.dart';
import 'package:daisy_frontend/views/block_page.dart';

class LandDetailsPage extends StatelessWidget {
  final Map<String, dynamic> land;

  const LandDetailsPage({super.key, required this.land});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Land Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('General Info'),
            _infoCard('Name', land['name']),
            _infoCard('Latitude', land['latitude']),
            _infoCard('Longitude', land['longitude']),
            const SizedBox(height: 20),

            _sectionTitle('Environment'),
            _infoCard('Humidity', land['current_humidity']),
            _infoCard('Temperature', land['current_temperature']),
            if (land.containsKey('wind_speed'))
              _infoCard('Wind Speed', land['wind_speed']),
            if (land.containsKey('evapotranspiration'))
              _infoCard('Evapotranspiration', land['evapotranspiration']),
            if (land.containsKey('rainfall_pattern'))
              _infoCard('Rainfall Pattern', land['rainfall_pattern']),
            const SizedBox(height: 30),

            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showEditDialog(context),
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Land"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _confirmDeleteLand(context),
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete Land"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocksPage(landId: land["id"]),
                        ),
                      );
                    },
                    icon: const Icon(Icons.spa),
                    label: const Text("Show All Plants"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoCard(String label, dynamic value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value?.toString() ?? '--'),
      ),
    );
  }

  void _showEditDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (_) => CreateLandDialog(
            initialName: land['name'],
            initialLatitude: land['latitude'],
            initialLongitude: land['longitude'],
            title: 'Edit Land',
            confirmText: 'Save',
          ),
    );

    if (result != null) {
      try {
        await LandsService.editLand(land['id'], result);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Land updated')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Edit failed: $e')));
        }
      }
    }
  }

  void _confirmDeleteLand(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: "Confirm Delete",
      message: "Are you sure you want to delete this land?",
    );

    if (confirmed == true) {
      try {
        await LandsService.deleteLand(land["id"]);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Land deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
        }
      }
    }
  }
}
