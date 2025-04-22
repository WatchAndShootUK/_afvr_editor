import 'package:afvr_editor/ui/ui_elements/item_tile.dart';
import 'package:afvr_editor/widgets/weapon_editor_dialog.dart';
import 'package:flutter/material.dart';
import '../globals.dart';

class WeaponsTab extends StatefulWidget {
  const WeaponsTab({super.key});

  @override
  State<WeaponsTab> createState() => _WeaponsTabState();
}

class _WeaponsTabState extends State<WeaponsTab> {
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
                await showWeaponEditorDialog(context, {});
                setState(() {});
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Weapon"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: GridView.builder(
              itemCount: weapons.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final weapon = weapons[index];
                return ItemTile(
                  item: weapon,
                  onTap: () => setState(() {}),
                  filterKey: 'weapon', // ✅ Rebuild after weapon is updated
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
