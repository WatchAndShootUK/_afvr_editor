// lib/ui/ui_elements/weapon_tile.dart

// ignore_for_file: deprecated_member_use

import 'package:afvr_editor/widgets/armour_editor_dialog.dart';
import 'package:afvr_editor/widgets/sensor_editor_dialog.dart';
import 'package:afvr_editor/widgets/vehicle_editor_dialog.dart';
import 'package:flutter/material.dart';
import '../../widgets/weapon_editor_dialog.dart';

class ItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap; // Optional for flexibility
  final String filterKey;

  const ItemTile({
    super.key,
    required this.item,
    required this.filterKey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String? image =
        item['image'] is String
            ? item['image']
            : (item['images'] is Map && item['images'].isNotEmpty)
            ? item['images'].keys.first
            : (item['images'] is List &&
                item['images'].isNotEmpty &&
                item['images'].first is String)
            ? item['images'].first
            : null;

    final String? imageUrl =
        (image != null && image.isNotEmpty)
            ? 'https://raw.githubusercontent.com/WatchAndShootUK/_afvr_lib/main/$image'
            : null;

    final name = item['name'] ?? 'Unnamed Weapon';

    return GestureDetector(
      onTap: () async {
        if (filterKey == 'weapon') {
          await showWeaponEditorDialog(context, item);
        } else if (filterKey == 'armour') {
          await showArmourEditorDialog(context, item);
        } else if (filterKey == 'sensor') {
          await showSensorEditorDialog(context, item);
        } else if (filterKey == 'vehicle') {
          await showEditorDialog(context, item);
        }
        if (onTap != null) onTap!();
      },
      child: Container(
        decoration: BoxDecoration(
          image:
              imageUrl != null
                  ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4),
                      BlendMode.darken,
                    ),
                  )
                  : null,
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    (item['status']?.toString().toLowerCase() == 'draft')
                        ? Colors.red
                        : Colors.white,

                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
