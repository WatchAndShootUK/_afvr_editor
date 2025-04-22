// lib/widgets/type_picker.dart

import 'package:afvr_editor/utils/proper_case.dart';
import 'package:flutter/material.dart';

Future<String?> showTypePicker(BuildContext context, Map<String,dynamic> vehicle) async {
  const typeOptions = {
    'recce': 'intelligence & reconnaissance',
    'mbt': 'main battle tank',
    'ifv': 'infantry fighting vehicle',
    'apc': 'armoured personnel carrier',
    'pm': 'protected mobility',
    'comd': 'command',
    'at': 'anti tank',
    'arty': 'artillery',
    'ad': 'air defence',
    'ew': 'electronic warfare',
    'eng': 'engineer',
    'rec': 'recovery',
    'radar': 'radar',
    'log': 'logistics',
    'med': 'medical',
    'rw': 'rotary wing',
  };

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text('Select type', style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 400,
          height: 400,
          child: ListView(
            children:
                typeOptions.entries
                    .where(
                      (e) => !vehicle['types'].contains(e.key.toUpperCase()),
                    )
                    .map((e) {
                      return ListTile(
                        title: Text(
                          properCase(e.value),
                          style: const TextStyle(color: Colors.white),
                        ),
                        tileColor: Colors.grey[850],
                        onTap:
                            () => Navigator.pop(context, e.key.toUpperCase()),
                      );
                    })
                    .toList(),
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
