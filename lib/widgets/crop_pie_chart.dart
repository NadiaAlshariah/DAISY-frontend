import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:daisy_frontend/services/block_service.dart';

class CropPieChart extends StatefulWidget {
  final String? landId;

  const CropPieChart({super.key, this.landId});

  @override
  State<CropPieChart> createState() => _CropPieChartState();
}

class _CropPieChartState extends State<CropPieChart> {
  late Future<Map<String, dynamic>> _cropData;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _cropData = BlockService.getCropDistribution(landId: widget.landId);
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
          return _buildEmptyChart(context);
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
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Blocks: $total',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showDetails = !_showDetails;
                    });
                  },
                  child: Text(
                    _showDetails ? 'Hide Details' : 'Show More Details',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            if (_showDetails) ...[
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      color: Colors.grey.shade200,
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 5,
                            child: Text(
                              'Crop',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Count',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...chartData.entries.map((entry) {
                      final crop = entry.key;
                      final count = entry.value.toInt();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 5, child: Text(crop)),
                            Expanded(flex: 3, child: Text('$count')),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PieChart(
          dataMap: const {"No Data": 1},
          colorList: [Colors.grey.shade300],
          chartRadius: MediaQuery.of(context).size.width / 2,
          chartType: ChartType.ring,
          ringStrokeWidth: 32,
          legendOptions: const LegendOptions(showLegends: false),
          chartValuesOptions: const ChartValuesOptions(showChartValues: false),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            "No crop data available",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
