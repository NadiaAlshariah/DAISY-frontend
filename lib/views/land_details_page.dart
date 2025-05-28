import 'package:flutter/material.dart';
import 'package:daisy_frontend/services/lands_service.dart';
import 'package:daisy_frontend/widgets/create_land_dialog.dart';
import 'package:daisy_frontend/widgets/show_confirm_dialog.dart';
import 'package:daisy_frontend/views/block_page.dart';
import 'package:daisy_frontend/widgets/crop_pie_chart.dart';
import 'package:daisy_frontend/widgets/weather_card.dart';

class LandDetailsPage extends StatelessWidget {
  final Map<String, dynamic> land;

  const LandDetailsPage({super.key, required this.land});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Land Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeleteLand(context),
          ),
        ],
      ),
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

            CropPieChart(landId: land['id']),

            const SizedBox(height: 20),

            _sectionTitle('Live Weather'),
            FutureBuilder<Map<String, dynamic>>(
              future: LandsService.getLiveWeatherForLand(land['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _infoCard('Weather Error', snapshot.error.toString());
                }

                final weather = snapshot.data!;
                return WeatherCard(weather: weather);
              },
            ),
            const SizedBox(height: 30),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocksPage(landId: land["id"]),
                        ),
                      );
                    },
                    icon: const Icon(Icons.spa, size: 28),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        "Show All Plants",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
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
            initialRegion:
                land['region']
                    ?.toString()
                    .toLowerCase(), // optional lowercase if you stored uppercase
            initialWifiSsid: land['wifi_ssid'],
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
