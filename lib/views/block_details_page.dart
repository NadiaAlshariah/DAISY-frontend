import 'package:flutter/material.dart';
import 'package:daisy_frontend/services/block_service.dart';
import 'package:daisy_frontend/widgets/yield_prediciton.dart';
import 'package:daisy_frontend/widgets/irrigation_history_chart.dart';

class BlockDetailsPage extends StatefulWidget {
  final Map<String, dynamic> block;

  const BlockDetailsPage({super.key, required this.block});

  @override
  State<BlockDetailsPage> createState() => _BlockDetailsPageState();
}

class _BlockDetailsPageState extends State<BlockDetailsPage> {
  Map<String, dynamic>? yieldPrediction;
  bool loadingPrediction = true;
  List<Map<String, dynamic>> irrigationHistory = [];
  Map<String, dynamic>? latestIrrigation;
  bool loadingIrrigation = true;

  @override
  void initState() {
    super.initState();
    fetchYieldPrediction();
    fetchIrrigationData();
  }

  Future<void> fetchIrrigationData() async {
    try {
      final latest = await BlockService.getLatestIrrigationPrediction(
        widget.block['land_id'],
        widget.block['id'],
      );

      final history = await BlockService.getIrrigationPredictionHistory(
        widget.block['land_id'],
        widget.block['id'],
      );

      setState(() {
        latestIrrigation = latest;
        irrigationHistory = history;
        loadingIrrigation = false;
        print(history);
      });
    } catch (e) {
      setState(() => loadingIrrigation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load irrigation data: $e")),
      );
    }
  }

  Future<void> fetchYieldPrediction() async {
    try {
      final data = await BlockService.getLatestYieldPrediction(
        widget.block['id'],
        widget.block["land_id"],
      );
      setState(() {
        yieldPrediction = data;
        loadingPrediction = false;
      });
    } catch (e) {
      setState(() => loadingPrediction = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load yield prediction: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final block = widget.block;
    final cropType = _safeEnum(block['crop_type']);
    final soilMoisture = block['soil_moisture'];
    final fertilizerUsed = block['fertilizer_uesd'] == true;
    final irrigationUsed = block['irrigation_used'] == true;
    final plantedAt = _formatDate(block['planted_at']);
    final sensorId = block['sensor_id'] ?? 'None';

    return Scaffold(
      appBar: AppBar(title: const Text('Block Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildIconRow("Crop Type", cropType, Icons.grass),
            const SizedBox(height: 12),
            _buildMoistureCard(soilMoisture),
            const SizedBox(height: 12),
            _buildStatusChips(fertilizerUsed, irrigationUsed),
            const SizedBox(height: 12),
            _buildIconRow("Planted At", plantedAt, Icons.event),
            const SizedBox(height: 12),
            _buildIconRow("Sensor ID", sensorId, Icons.sensors),
            const SizedBox(height: 20),

            YieldPredictionCard(
              predictions: yieldPrediction != null ? [yieldPrediction!] : [],
              isLoading: loadingPrediction,
            ),

            const SizedBox(height: 20),
            if (loadingIrrigation)
              const Center(child: CircularProgressIndicator())
            else
              IrrigationPredictionChart(
                history: irrigationHistory,
                latest: latestIrrigation,
                title: "Irrigation Prediction History",
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconRow(String title, dynamic value, IconData icon) {
    final displayValue = _formatValue(value);

    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(displayValue, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildMoistureCard(dynamic value) {
    double moisture = value is num ? value.toDouble() : 0;

    Color color;
    if (moisture < 15) {
      color = Colors.red;
    } else if (moisture < 35) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Soil Moisture",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(begin: Colors.grey, end: color),
              duration: const Duration(milliseconds: 600),
              builder: (context, animatedColor, child) {
                return Row(
                  children: [
                    Icon(Icons.water_drop, color: animatedColor),
                    const SizedBox(width: 6),
                    Text(
                      "${moisture.toStringAsFixed(2)}%",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: animatedColor,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: moisture.clamp(0, 100) / 100,
              color: color,
              backgroundColor: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChips(bool fertilizer, bool irrigation) {
    return Row(
      children: [
        Chip(
          label: const Text(
            "Fertilizer",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          avatar: const Icon(Icons.science, color: Colors.white),
          backgroundColor:
              fertilizer ? const Color(0xFF66BB6A) : const Color(0xFFFF8A80),
        ),
        const SizedBox(width: 8),
        Chip(
          label: const Text(
            "Irrigation",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          avatar: const Icon(Icons.water, color: Colors.white),
          backgroundColor:
              irrigation ? const Color(0xFF66BB6A) : const Color(0xFFFF8A80),
        ),
      ],
    );
  }

  String _formatValue(dynamic value) {
    if (value is String) return value;
    if (value is Map && value.containsKey('value'))
      return value['value'].toString();
    return value?.toString() ?? '--';
  }

  String _safeEnum(dynamic value) {
    return _formatValue(value);
  }

  String _formatDate(dynamic value) {
    if (value == null) return '--';

    if (value is Map && value.containsKey(r'$date')) {
      value = value[r'$date'];
    }

    if (value is String) {
      try {
        final dateTime = DateTime.parse(value);
        return "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}";
      } catch (_) {
        return value;
      }
    }

    return value.toString();
  }

  String _twoDigits(int n) => n < 10 ? '0$n' : '$n';
}
