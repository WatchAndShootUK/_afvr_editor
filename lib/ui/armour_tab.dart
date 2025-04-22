import 'package:afvr_editor/ui/ui_elements/item_tile.dart';
import 'package:flutter/material.dart';
import '../globals.dart';
import '../widgets/armour_editor_dialog.dart';

class ArmourTab extends StatefulWidget {
  const ArmourTab({super.key});

  @override
  State<ArmourTab> createState() => _ArmourTabState();
}

class _ArmourTabState extends State<ArmourTab> {
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
                await showArmourEditorDialog(context, {});
                setState(() {});
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Armour"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              itemCount: armours.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final armour = armours[index];
                return ItemTile(
                  item: armour,
                  onTap: () => setState(() {}),
                  filterKey: 'armour', // ✅ Rebuild after weapon is updated
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
