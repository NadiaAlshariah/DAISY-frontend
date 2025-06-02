import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class IrrigationPredictionChart extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final Map<String, dynamic>? latest;
  final String? title;

  const IrrigationPredictionChart({
    super.key,
    required this.history,
    required this.latest,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Text("No irrigation prediction history available.");
    }

    final List<FlSpot> spots = [];
    final List<String> labels = [];

    for (int i = 0; i < history.length; i++) {
      final item = history[i];
      final value =
          double.tryParse(item['water_requirement']?.toString() ?? '') ?? 0.0;

      final rawDate = item['created_at'];
      final dateStr = _extractDate(rawDate);
      labels.add(dateStr ?? 'N/A');

      spots.add(FlSpot(i.toDouble(), value));
    }

    // Calculate min/max Y with padding
    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    minY = (minY - 1).clamp(0, minY);
    maxY = (maxY + 1);

    final bool showXLabels = spots.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: showXLabels,
                    interval: 1,
                    getTitlesWidget: (value, _) {
                      int index = value.toInt();
                      return Text(
                        index < labels.length ? labels[index] : '',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget:
                        (value, _) => Text(
                          '${value.toStringAsFixed(1)}L',
                          style: const TextStyle(fontSize: 10),
                        ),
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 2,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (latest != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Latest Prediction: ${latest!['water_requirement'] ?? '--'} mm",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                "Created At: ${_extractDate(latest!['created_at']) ?? '--'}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
      ],
    );
  }

  String? _extractDate(dynamic rawDate) {
    try {
      if (rawDate is Map && rawDate.containsKey(r'$date')) {
        return rawDate[r'$date'].toString().split('T').first;
      }
      if (rawDate is String) {
        return DateTime.parse(rawDate).toIso8601String().split('T').first;
      }
    } catch (_) {}
    return null;
  }
}
