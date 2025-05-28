import 'package:flutter/material.dart';
import 'package:daisy_frontend/services/lands_service.dart';
import 'package:daisy_frontend/widgets/create_land_dialog.dart';
import 'package:daisy_frontend/widgets/land_card.dart';

class LandsPage extends StatefulWidget {
  const LandsPage({super.key});

  @override
  State<LandsPage> createState() => _LandsPageState();
}

class _LandsPageState extends State<LandsPage> {
  late Future<List<Map<String, dynamic>>> _landsFuture;

  @override
  void initState() {
    super.initState();
    _loadLands();
  }

  void _loadLands() {
    setState(() {
      _landsFuture = LandsService.getUserLands();
    });
  }

  Future<void> _handleCreateLand() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const CreateLandDialog(),
    );

    if (result != null) {
      try {
        // ✅ Send the full map directly
        await LandsService.createLand(result);
        _loadLands();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lands'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _landsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final lands = snapshot.data!;
          if (lands.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "You don't have any lands.\nAdd one now!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    _buildAddButton(),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildAddButton(),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: lands.length,
                  itemBuilder: (context, index) {
                    final land = lands[index];
                    return LandCard(land: land);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleCreateLand,
        icon: const Icon(Icons.add),
        label: const Text('Add Land'),
      ),
    );
  }
}
