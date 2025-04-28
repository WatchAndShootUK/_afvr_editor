import 'dart:convert';

import 'package:afvr_editor/globals.dart';
import 'package:afvr_editor/ui/ui_elements/multiline_paste_dialog.dart';
import 'package:afvr_editor/widgets/vehicle_editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

IconButton aiAddButton(BuildContext context) {
  Future<void> showNameCountryDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController countryController = TextEditingController();

    Future<void> addAIVehicle(String stringReceived) async {
      final uuid = const Uuid();

      Map<String, dynamic> emptyVehicle = {
        'uid': uuid.v4(),
        'name': nameController,
        'family': '',
        'crew': '',
        'status': 'draft',
        'description': '',
        'types': [],
        'armament': [''],
        'protection': [''],
        'sensors': [''],
        'images': [],
        'recognising_features': {},
        'about': {
          'alliance': '',
          'in_service_date': '',
          'manufacturer': '',
          'operators': '',
          'origin_country': '',
          'out_service_date': '',
        },
        'dimensions': {'height': '', 'length': '', 'weight': '', 'width': ''},
        'engine': {
          'amphibious': '',
          'fuel': '',
          'horsepower': '',
          'max_speed': '',
          'range': '',
        },
        'other_data': {},
      };

      Map<String, dynamic> aiVehicle = json.decode(stringReceived);
      aiVehicle.forEach((key, value) {
        if (emptyVehicle[key] != value) {
          emptyVehicle[key] = value;
        }
      });

      final updated = await showEditorDialog(context, emptyVehicle);
      if (updated != null) {
        final index = vehicles.indexWhere((w) => w['uid'] == updated['uid']);
        if (index >= 0) {
          vehicles[index] = updated;
        } else {
          vehicles.add(updated);
        }
      }
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: countryController,
                decoration: InputDecoration(labelText: 'Country'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close without doing anything
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close after submitting
                String stringReceived;
                stringReceived = await showMultilinePasteDialog(
                  context,
                  nameController.text.trim(),
                  countryController.text.trim(),
                );
                addAIVehicle(stringReceived);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  return IconButton(
    icon: Icon(Icons.auto_awesome),
    color: Colors.white,
    iconSize: 28,
    onPressed: () => showNameCountryDialog(context),
  );
}
