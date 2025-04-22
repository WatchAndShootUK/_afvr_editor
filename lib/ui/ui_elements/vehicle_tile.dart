// ignore_for_file: deprecated_member_use

import 'package:afvr_editor/globals.dart';
import 'package:afvr_editor/widgets/vehicle_editor_dialog.dart';
import 'package:flutter/material.dart';

class VehicleTile extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback? onTap;

  const VehicleTile({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageList = vehicle['images'];
    final String? imageUrl = (imageList is List && imageList.isNotEmpty)
        ? 'https://raw.githubusercontent.com/WatchAndShootUK/_afvr_lib/main/${imageList.first}'
        : null;

    final name = vehicle['name'] ?? 'Unknown';

    return GestureDetector(
onTap: () async {
  final updated = await showEditorDialog(context, vehicle);
  if (updated != null) {
    final index = vehicles.indexWhere((w) => w['uid'] == updated['uid']);
    if (index >= 0) {
      vehicles[index] = updated;
    } else {
      vehicles.add(updated);
    }
    if (onTap != null) onTap!(); // ✅ Refresh the parent UI
  }
},
      child: Container(
        decoration: BoxDecoration(
          image: imageUrl != null
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
                color: vehicle['status'] == 'complete' ? Colors.white : Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
