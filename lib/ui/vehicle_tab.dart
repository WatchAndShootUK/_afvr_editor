// ignore_for_file: use_build_context_synchronously

import 'package:afvr_editor/ui/ui_elements/ai_add_button.dart';
import 'package:afvr_editor/ui/ui_elements/item_tile.dart';
import 'package:flutter/material.dart';
import 'package:afvr_editor/widgets/vehicle_editor_dialog.dart';
import '../globals.dart';

class VehicleTab extends StatefulWidget {
  const VehicleTab({super.key});

  @override
  State<VehicleTab> createState() => _VehicleTabState();
}

class _VehicleTabState extends State<VehicleTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  showEditorDialog(context, {});
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Vehicle"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
              ),
              aiAddButton(context),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              itemCount: vehicles.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return ItemTile(
                  item: vehicle,
                  onTap: () => setState(() {}),
                  filterKey: 'vehicle', // ✅ Rebuild after weapon is updated
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
