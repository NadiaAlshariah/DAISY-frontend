import 'package:flutter/material.dart';
import 'package:daisy_frontend/auth/service/auth_service.dart';
import 'package:daisy_frontend/services/lands_service.dart';
import 'package:daisy_frontend/views/lands_page.dart';
import 'package:daisy_frontend/views/settings/settings_page.dart';
import 'package:daisy_frontend/widgets/land_card.dart';
import 'package:daisy_frontend/widgets/crop_pie_chart.dart';
import 'package:daisy_frontend/widgets/yield_prediciton.dart';
import 'package:daisy_frontend/widgets/water_summary_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  late Future<List<Map<String, dynamic>>> _landsFuture;
  late Future<List<Map<String, dynamic>>> _userPredictionsFuture;
  Map<String, dynamic>? waterSummary;
  bool loadingWaterSummary = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _refreshData();
  }

  void _loadUsername() async {
    final result = await AuthService.getUsername();
    setState(() {
      username = result;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _landsFuture = LandsService.getUserLands();
      _userPredictionsFuture = LandsService.getLatestYieldPredictionsForUser();
      loadingWaterSummary = true;
    });

    try {
      final summary = await LandsService.getWaterSummaryForUser();
      setState(() {
        waterSummary = summary;
        loadingWaterSummary = false;
      });
    } catch (e) {
      setState(() => loadingWaterSummary = false);
    }

    await Future.wait([_landsFuture, _userPredictionsFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _landsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading lands: ${snapshot.error}'),
            );
          }

          final lands = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username != null ? 'Welcome, $username 👋' : 'Welcome 👋',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// Lands Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lands (${lands.length})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LandsPage(),
                            ),
                          );
                          if (result == true) {
                            await _refreshData();
                          }
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...lands.take(3).map((land) => LandCard(land: land)).toList(),

                  const SizedBox(height: 24),
                  const Text(
                    'Your Yield Prediction Summary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _userPredictionsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Text('Prediction Error: ${snapshot.error}');
                      }

                      final predictions = snapshot.data ?? [];
                      return YieldPredictionCard(
                        predictions: predictions,
                        isLoading: false,
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Your Irrigation Summary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  loadingWaterSummary
                      ? const Center(child: CircularProgressIndicator())
                      : waterSummary == null
                      ? const Text("No irrigation data found.")
                      : WaterSummaryCard(summary: waterSummary!),

                  const SizedBox(height: 32),
                  const CropPieChart(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
