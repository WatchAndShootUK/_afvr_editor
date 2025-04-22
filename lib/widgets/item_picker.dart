import 'package:flutter/material.dart';

Future<String?> showItemPicker({
  required BuildContext context,
  required String title,
  required List<Map<String, dynamic>> items,
  required Map<String, dynamic> vehicle,
  required String filterKey,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 400,
          height: 400,
          child: ListView(
            children:
                items.map((item) {
                  final name = item['name'] ?? 'Unnamed';
                  final alreadyExists = (vehicle[filterKey] as List).contains(
                    name,
                  );

                  if (alreadyExists) return const SizedBox.shrink(); // skip it

                  return ListTile(
                    title: Text(
                      name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    tileColor: Colors.grey[850],
                    onTap: () => Navigator.pop(context, name),
                  );
                }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
