import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:daisy_frontend/services/block_service.dart';

class CropsSection extends StatefulWidget {
  const CropsSection({super.key});

  @override
  State<CropsSection> createState() => _CropsSectionState();
}

class _CropsSectionState extends State<CropsSection> {
  late Future<Map<String, dynamic>> _cropData;

  @override
  void initState() {
    super.initState();
    _cropData = BlockService.getCropDistribution();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _cropData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading crop data"));
        }

        final data = snapshot.data!;
        final total = data["total_blocks"];
        final Map<String, dynamic> cropMap = Map<String, dynamic>.from(
          data["crop_distribution"],
        );
        final Map<String, double> chartData = {
          for (var entry in cropMap.entries)
            entry.key: (entry.value as num).toDouble(),
        };

        if (total == 0 || chartData.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crop Distribution',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              PieChart(
                dataMap: const {"No Data": 1},
                colorList: [Colors.grey.shade300],
                chartRadius: MediaQuery.of(context).size.width / 2,
                chartType: ChartType.ring,
                ringStrokeWidth: 32,
                legendOptions: const LegendOptions(showLegends: false),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValues: false,
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "No crop data available",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crop Distribution',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            PieChart(
              dataMap: chartData,
              chartRadius: MediaQuery.of(context).size.width / 2,
              chartType: ChartType.ring,
              ringStrokeWidth: 32,
              legendOptions: const LegendOptions(showLegendsInRow: false),
              chartValuesOptions: const ChartValuesOptions(
                showChartValuesInPercentage: true,
                showChartValues: true,
              ),
            ),
            const SizedBox(height: 20),
            ...chartData.entries.map(
              (e) => Text(
                "${e.key}: ${(e.value / total * 100).toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}
