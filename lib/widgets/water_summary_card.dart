import 'package:flutter/material.dart';

class WaterSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;

  const WaterSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final createdAt = summary['created_at'];
    final total = summary['total_water'];
    final avg = summary['average_water'];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop, size: 40, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Irrigation Water Summary",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("Total: ${total ?? '--'} liters"),
                Text("Average: ${avg ?? '--'} liters"),
                if (createdAt != null)
                  Text("Last Updated: ${_formatDate(createdAt)}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic rawDate) {
    try {
      if (rawDate is Map && rawDate.containsKey(r'$date')) {
        return rawDate[r'$date'].toString().split('T').first;
      }
      if (rawDate is String) {
        return DateTime.parse(rawDate).toIso8601String().split('T').first;
      }
    } catch (_) {}
    return "--";
  }
}
