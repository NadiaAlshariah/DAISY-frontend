import 'package:flutter/material.dart';
import 'package:daisy_frontend/views/land_details_page.dart';

class LandCard extends StatelessWidget {
  final Map<String, dynamic> land;

  const LandCard({super.key, required this.land});

  @override
  Widget build(BuildContext context) {
    final latitude = land['latitude'];
    final longitude = land['longitude'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: ListTile(
        leading: const Icon(Icons.terrain, color: Colors.green),
        title: Text(
          land['name'] ?? 'Unnamed Land',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Lat: ${_formatCoord(latitude)} | Lng: ${_formatCoord(longitude)}',
          style: const TextStyle(fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LandDetailsPage(land: land)),
          );
        },
      ),
    );
  }

  String _formatCoord(dynamic value) {
    if (value is num) {
      return value.toStringAsFixed(4);
    }
    return '--';
  }
}
