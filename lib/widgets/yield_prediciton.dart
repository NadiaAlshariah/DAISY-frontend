import 'package:flutter/material.dart';

class YieldPredictionCard extends StatelessWidget {
  final List<Map<String, dynamic>> predictions;
  final bool isLoading;

  const YieldPredictionCard({
    super.key,
    required this.predictions,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (predictions.isEmpty) {
      return const Text("No yield predictions available.");
    }

    double total = 0;
    for (final p in predictions) {
      total += (p['yield_tons_per_hectare'] ?? 0).toDouble();
    }

    final avg = total / predictions.length;
    final totalKgPerM2 = (total * 0.1).toStringAsFixed(3);
    final avgKgPerM2 = (avg * 0.1).toStringAsFixed(3);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.agriculture, size: 40, color: Colors.green),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Yield Prediction Summary",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Total: ${total.toStringAsFixed(2)} t/ha | $totalKgPerM2 kg/m²",
                ),
                Text(
                  "Average: ${avg.toStringAsFixed(2)} t/ha | $avgKgPerM2 kg/m²",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
