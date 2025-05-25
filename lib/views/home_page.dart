import 'package:daisy_frontend/widgets/crop_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:daisy_frontend/auth/service/auth_service.dart';
import 'package:daisy_frontend/services/lands_service.dart';
import 'package:daisy_frontend/views/lands_page.dart';
import 'package:daisy_frontend/widgets/land_card.dart';
import 'package:daisy_frontend/views/settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  late Future<List<Map<String, dynamic>>> _landsFuture;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _refreshLands();
  }

  void _loadUsername() async {
    final result = await AuthService.getUsername();
    setState(() {
      username = result;
    });
  }

  Future<void> _refreshLands() async {
    setState(() {
      _landsFuture = LandsService.getUserLands();
    });
    await _landsFuture;
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
            onRefresh: _refreshLands,
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
                            await _refreshLands();
                          }
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...lands.take(3).map((land) => LandCard(land: land)).toList(),
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
