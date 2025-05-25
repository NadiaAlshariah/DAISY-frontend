import 'package:flutter/material.dart';

class CreateBlockDialog extends StatefulWidget {
  final String landId;

  const CreateBlockDialog({super.key, required this.landId});

  @override
  State<CreateBlockDialog> createState() => _CreateBlockDialogState();
}

class _CreateBlockDialogState extends State<CreateBlockDialog> {
  static const soilTypes = ["sandy", "clay", "loamy", "peaty", "chalky"];
  static const cropTypes = ["wheat", "corn", "rice", "potato"];
  static const growthStates = [
    "seed",
    "germinating",
    "vegetative",
    "budding",
    "flowering",
    "ripening",
    "harvested",
  ];

  String? selectedSoilType;
  String? selectedCropType;
  String? selectedGrowthState;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Block"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSoilType,
              items:
                  soilTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => selectedSoilType = value),
              decoration: const InputDecoration(labelText: "Soil Type"),
            ),
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
            DropdownButtonFormField<String>(
              value: selectedGrowthState,
              items:
                  growthStates
                      .map(
                        (state) =>
                            DropdownMenuItem(value: state, child: Text(state)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => selectedGrowthState = value),
              decoration: const InputDecoration(labelText: "Growth State"),
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
            if (selectedSoilType == null ||
                selectedCropType == null ||
                selectedGrowthState == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please select all dropdown values"),
                ),
              );
              return;
            }

            final data = {
              "land_id": widget.landId,
              "soil_type": selectedSoilType,
              "crop_type": selectedCropType,
              "growth_state": selectedGrowthState,
              "planted_at": DateTime.now().toIso8601String(),
            };

            Navigator.of(context).pop(data);
          },
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
