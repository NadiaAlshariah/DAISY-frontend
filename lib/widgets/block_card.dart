import 'package:flutter/material.dart';
import 'package:daisy_frontend/views/block_details_page.dart';

class BlockCard extends StatelessWidget {
  final Map<String, dynamic> block;

  const BlockCard({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final cropType = block['crop_type'] ?? 'N/A';
    final soilMoisture = block['soil_moisture'];
    final fertilizerUsed = block['fertilizer_uesd'] == true;
    final irrigationUsed = block['irrigation_used'] == true;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: const Icon(Icons.grass, color: Colors.green),
        title: Text(
          'Crop: $cropType',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Soil Moisture: "),
                TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                    begin: Colors.grey,
                    end: _getMoistureColor(soilMoisture),
                  ),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, color, child) {
                    return Row(
                      children: [
                        Icon(Icons.water_drop, color: color, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${_format(soilMoisture)}%",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            Text('Fertilizer Used: ${fertilizerUsed ? "Yes" : "No"}'),
            Text('Irrigation Used: ${irrigationUsed ? "Yes" : "No"}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BlockDetailsPage(block: block)),
          );
        },
      ),
    );
  }

  String _format(dynamic value) {
    if (value is num) return value.toStringAsFixed(2);
    return '--';
  }

  Color _getMoistureColor(dynamic value) {
    if (value is! num) return Colors.grey;
    if (value < 15) return Colors.red;
    if (value < 35) return Colors.orange;
    return Colors.green;
  }
}
