// lib/widgets/sensor_editor_dialog.dart

// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'package:afvr_editor/services/item_save_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;
import '../globals.dart';

Future<Map<String, dynamic>?> showSensorEditorDialog(
  BuildContext context,
  Map<String, dynamic> originalSensor,
) {
  final uuid = const Uuid();

  final sensor =
      originalSensor.isEmpty
          ? {
            'uid': uuid.v4(),
            'name': '',
            'description': '',
            'image': '',
            'preview': '',
          }
          : Map<String, dynamic>.from(originalSensor);

  final nameController = TextEditingController(text: sensor['name']);
  final descController = TextEditingController(text: sensor['description']);

  String generateUID(String baseName) {
    final randomId = uuid.v4().replaceAll('-', '').substring(0, 20);
    return '${baseName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}_$randomId.jpg';
  }

  bool isValid() {
    return sensor['name'].toString().trim().isNotEmpty &&
        sensor['description'].toString().trim().isNotEmpty &&
        sensor['image'].toString().trim().isNotEmpty;
  }

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder:
        (_) => StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                backgroundColor: Colors.black,
                title: Text(
                  'Edit Sensor: ${sensor['name'] ?? 'New Sensor'}',
                  style: const TextStyle(color: Colors.white),
                ),
                content: SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Name',
                            filled: true,
                            fillColor:
                                nameController.text.trim().isEmpty
                                    ? Colors.yellow[700]
                                    : Colors.grey[850],
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (val) => sensor['name'] = val,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            filled: true,
                            fillColor:
                                descController.text.trim().isEmpty
                                    ? Colors.yellow[700]
                                    : Colors.grey[850],
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (val) => sensor['description'] = val,
                        ),
                        const SizedBox(height: 12),
                        if ((sensor['preview'] ?? '').isNotEmpty ||
                            (sensor['image'] ?? '').isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                sensor['preview']?.isNotEmpty == true
                                    ? sensor['preview']
                                    : 'https://raw.githubusercontent.com/WatchAndShootUK/_afvr_lib/main/${sensor['image']}',
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const Text(
                                      'Image load failed',
                                      style: TextStyle(color: Colors.red),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sensor['image'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () async {
                            final upload = html.FileUploadInputElement();
                            upload.accept = 'image/*';
                            upload.click();
                            await upload.onChange.first;
                            final files = upload.files;
                            if (files != null && files.isNotEmpty) {
                              final reader = html.FileReader();
                              reader.readAsDataUrl(files.first);
                              reader.onLoadEnd.listen((_) {
                                final previewUrl = reader.result as String;
                                final newName = generateUID(
                                  sensor['name'] ?? 'sensor',
                                );
                                sensor['image'] = newName;
                                sensor['preview'] = previewUrl;
                                (context as Element).markNeedsBuild();
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Upload Image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                    onPressed: () {
                      if (isValid()) {
                        itemSaveService(
                          context,
                          sensor,
                          sensors,
                          'sensors.json',
                        );
                      } else {
                        final List<String> errors = [];
                        if (sensor['name'].toString().trim().isEmpty) {
                          errors.add("Name is required.");
                        }
                        if (sensor['description'].toString().trim().isEmpty) {
                          errors.add("Description is required.");
                        }
                        if (sensor['image'].toString().trim().isEmpty) {
                          errors.add("Image is required.");
                        }
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: Colors.black,
                                title: const Text(
                                  'Missing Fields',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      errors
                                          .map(
                                            (e) => Text(
                                              "• $e",
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "OK",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      }
                    },
                    child: const Text(
                      'SAVE',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ),
  );
}
