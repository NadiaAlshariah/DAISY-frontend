import 'package:flutter/material.dart';
import 'package:daisy_frontend/services/block_service.dart';

class BlocksPage extends StatefulWidget {
  final String landId;

  const BlocksPage({super.key, required this.landId});

  @override
  State<BlocksPage> createState() => _BlocksPageState();
}

class _BlocksPageState extends State<BlocksPage> {
  late Future<List<Map<String, dynamic>>> _blocksFuture;

  @override
  void initState() {
    super.initState();
    _blocksFuture = BlockService.getBlocksByLandId(widget.landId);
  }

  Future<void> _handleAddBlock() async {
    final typeController = TextEditingController();
    final areaController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Add New Block"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: "Type"),
                ),
                TextField(
                  controller: areaController,
                  decoration: const InputDecoration(labelText: "Area (m²)"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final data = {
                    "type": typeController.text.trim(),
                    "area": double.tryParse(areaController.text) ?? 0.0,
                  };
                  Navigator.pop(context, data);
                },
                child: const Text("Create"),
              ),
            ],
          ),
    );

    if (result != null) {
      try {
        await BlockService.createBlock(widget.landId, result);
        setState(() {
          _blocksFuture = BlockService.getBlocksByLandId(widget.landId);
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Create failed: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Blocks")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _blocksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final blocks = snapshot.data!;
          if (blocks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "No plants in this land yet.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _handleAddBlock,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Block"),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleAddBlock,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Block"),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: blocks.length,
                  itemBuilder: (context, index) {
                    final block = blocks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text("Block ID: ${block["id"] ?? "--"}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Type: ${block["type"] ?? "N/A"}"),
                            Text("Area: ${block["area"] ?? "--"} m²"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
