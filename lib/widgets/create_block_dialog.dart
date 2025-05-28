import 'package:flutter/material.dart';
import 'package:daisy_frontend/services/block_service.dart';

class CreateBlockDialog extends StatefulWidget {
  final String landId;
  final Map<String, dynamic>? initialData; 

  const CreateBlockDialog({super.key, required this.landId, this.initialData});

  @override
  State<CreateBlockDialog> createState() => _CreateBlockDialogState();
}

class _CreateBlockDialogState extends State<CreateBlockDialog> {
  static const cropTypes = ["Cotton", "Rice", "Wheat", "Corn"];

  String? selectedCropType;
  String? selectedSensorId;
  bool fertilizerUsed = false;
  bool irrigationUsed = false;

  List<Map<String, dynamic>> sensors = [];
  bool isLoadingSensors = true;

  @override
  void initState() {
    super.initState();

    // Populate form fields if editing
    final data = widget.initialData;
    if (data != null) {
      selectedCropType = data["crop_type"];
      selectedSensorId = data["sensor_id"];
      fertilizerUsed = data["fertilizer_uesd"] ?? false;
      irrigationUsed = data["irrigation_used"] ?? false;
    }

    fetchAvailableSensors();
  }

  Future<void> fetchAvailableSensors() async {
    try {
      final fetchedSensors = await BlockService.getAvailableSensors(
        widget.landId,
      );
      setState(() {
        sensors = fetchedSensors;
        isLoadingSensors = false;
      });
    } catch (e) {
      setState(() => isLoadingSensors = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching sensors: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialData != null;

    return AlertDialog(
      title: Text(isEditing ? "Edit Block" : "Add New Block"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCropType,
              items:
                  cropTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => selectedCropType = value),
              decoration: const InputDecoration(labelText: "Crop Type"),
            ),
            isLoadingSensors
                ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
                : DropdownButtonFormField<String>(
                  value: selectedSensorId,
                  items:
                      sensors.map<DropdownMenuItem<String>>((sensor) {
                        final label =
                            '${sensor["mac_address"]} - Pin ${sensor["pin"]}';
                        return DropdownMenuItem<String>(
                          value: sensor["id"] as String,
                          child: Text(label),
                        );
                      }).toList(),
                  onChanged:
                      (value) => setState(() => selectedSensorId = value),
                  decoration: const InputDecoration(labelText: "Sensor"),
                ),
            SwitchListTile(
              title: const Text("Fertilizer Used"),
              value: fertilizerUsed,
              onChanged: (value) => setState(() => fertilizerUsed = value),
            ),
            SwitchListTile(
              title: const Text("Irrigation Used"),
              value: irrigationUsed,
              onChanged: (value) => setState(() => irrigationUsed = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedCropType == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select crop type")),
              );
              return;
            }

            final data = {
              "land_id": widget.landId,
              "crop_type": selectedCropType,
              "fertilizer_uesd": fertilizerUsed,
              "irrigation_used": irrigationUsed,
              if (selectedSensorId != null) "sensor_id": selectedSensorId,
            };

            Navigator.of(context).pop(data);
          },
          child: Text(isEditing ? "Update" : "Submit"),
        ),
      ],
    );
  }
}
