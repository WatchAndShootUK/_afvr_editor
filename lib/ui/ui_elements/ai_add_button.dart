import 'dart:convert';
import 'dart:html' as html;

import 'package:afvr_editor/ui/ui_elements/multiline_paste_dialog.dart';
import 'package:afvr_editor/widgets/vehicle_editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

ElevatedButton aiAddButton(BuildContext context) {
  Future<void> showNameCountryDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController countryController = TextEditingController();


    String generateClipBoardData(String vehicleName, String vehicleUser) {
      return '''

You are an AI assistant.
Return only a JSON object based on the following vehicle template (without source tags) for the $vehicleName. It is used by the military of $vehicleUser.
{
  "nickname": "",
  "family": "",
  "about": {
    "origin_country": "",
    "manufacturer": "",
    "operators": "",
    "alliance": "",
    "in_service_date": "",
    "out_service_date": ""
  },
  "crew": "",
  "description": "",
  "dimensions": {
    "length": "",
    "width": "",
    "height": "",
    "weight": ""
  },
  "engine": {
    "amphibious": "",
    "fuel": "",
    "horsepower": "",
    "max_speed": "",
    "range": ""
  },
  "other_data": {},
  "website_sources": []
}

Only return clean valid JSON, nothing else.

Prioritize sources in this order:
1. Manufacturer website
2. https://odin.tradoc.army.mil/WEG/List
3. https://armyrecognition.com/
4. Other trusted sites (including Wikipedia).

Rules:
- Do not replicate any information from "about", "dimensions", or "engine" into "other_data".
- "Operators" must be a country name (e.g., "Germany", not "German Army").
- "in_service_date" and "out_service_date" must be 4-digit years only.
- If you cannot find a value, leave it empty ("").
- The "description" must be between 60 and 100 words.
- Do not include any commentary, explanation, or extra text.
- Do not include any symbols that would break the JSON format (eg " or {)
- Other data is only to be Keys and Values (no Maps), keys are to be proper case.
- All dimension data must be in metres, metric tons and kilometres per hour (with the unit give for example 'm' or 't').
''';
    }

    Future<void> addAIVehicle() async {
      final uuid = const Uuid();

      Map<String, dynamic> emptyVehicle = {
        'uid': uuid.v4(),
        'name': nameController.text,
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
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData != null && clipboardData.text != null) {
        Map<String, dynamic> aiVehicle = json.decode(clipboardData.text!);
        aiVehicle.forEach((key, value) {
          if (emptyVehicle[key] != value) {
            emptyVehicle[key] = value;
          }
        });
      }

      showEditorDialog(context, emptyVehicle);
    }

    void showMultilinePasteDialog(
      BuildContext context,
      String vehicleName,
      String vehicleUser,
    ) async {
      html.window.open('https://chatgpt.com/', '_blank');
      Clipboard.setData(
        ClipboardData(text: generateClipBoardData(vehicleName, vehicleUser)),
      );

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Copy the AI JSON onto Clipboard and click OK.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  addAIVehicle();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
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
                showMultilinePasteDialog(
                  context,
                  nameController.text.trim(),
                  countryController.text.trim(),
                );
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  return ElevatedButton.icon(
    icon: Icon(Icons.auto_awesome),
    onPressed: () => showNameCountryDialog(context),
    label: const Text('Add Vehicle'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green[700],
      foregroundColor: Colors.white,
    ),
  );
}
