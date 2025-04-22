import 'package:afvr_editor/ui/ui_elements/item_tile.dart';
import 'package:flutter/material.dart';
import '../globals.dart';
import '../widgets/sensor_editor_dialog.dart';

class SensorsTab extends StatefulWidget {
  const SensorsTab({super.key});

  @override
  State<SensorsTab> createState() => _SensorsTabState();
}

class _SensorsTabState extends State<SensorsTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              onPressed: () async {
                await showSensorEditorDialog(context, {});
                setState(() {});
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Sensor"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              itemCount: sensors.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final sensor = sensors[index];
                return ItemTile(
                  item: sensor,
                  onTap: () => setState(() {}),
                  filterKey: 'sensor', // ✅ Rebuild after weapon is updated
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
