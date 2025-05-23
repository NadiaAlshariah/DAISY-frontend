import 'package:daisy_frontend/widgets/crop_section.dart';
import 'package:flutter/material.dart';
import 'package:daisy_frontend/auth/service/auth_service.dart';
import 'package:daisy_frontend/services/lands_service.dart';
import 'package:daisy_frontend/views/lands_page.dart';
import 'package:daisy_frontend/widgets/land_card.dart';

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
    _landsFuture = LandsService.getUserLands();
  }

  Future<void> _loadUsername() async {
    final result = await AuthService.getUsername();
    setState(() {
      username = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
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

          return SingleChildScrollView(
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LandsPage()),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...lands.take(3).map((land) => LandCard(land: land)).toList(),
                const SizedBox(height: 32),
                const CropsSection(),

                // Additional sections can go here
              ],
            ),
          );
        },
      ),
    );
  }
}
