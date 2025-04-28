import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:flutter/services.dart';

Future<String> showMultilinePasteDialog(
  BuildContext context,
  String vehicleName,
  String vehicleUser,
) async {
  TextEditingController _controller = TextEditingController();
  String returnValue = '';
  html.window.open('https://chatgpt.com/', '_blank');
  Clipboard.setData(
    ClipboardData(text: generateClipBoardData(vehicleName, vehicleUser)),
  );

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Paste JSON Here', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          child: TextField(
            controller: _controller,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[800],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              returnValue = _controller.text;
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
  return returnValue;
}

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
- All dimension data must be in metres, metric tons and kilometres per hour.
''';
}
