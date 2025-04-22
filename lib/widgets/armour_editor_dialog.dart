// lib/widgets/armour_editor_dialog.dart

// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'package:afvr_editor/services/item_save_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;
import '../globals.dart';

Future<Map<String, dynamic>?> showArmourEditorDialog(
  BuildContext context,
  Map<String, dynamic> originalArmour,
) {
  final uuid = const Uuid();

  final armour =
      originalArmour.isEmpty
          ? {
            'uid': uuid.v4(),
            'name': '',
            'description': '',
            'images': {},
            'preview': '',
          }
          : Map<String, dynamic>.from(originalArmour);

  final nameController = TextEditingController(text: armour['name']);
  final descController = TextEditingController(text: armour['description']);

  String generateUID(String baseName) {
    final randomId = uuid.v4().replaceAll('-', '').substring(0, 20);
    return '${baseName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}_$randomId.jpg';
  }

  String? getFirstImageName() {
    if (armour['images'] is Map && armour['images'].isNotEmpty) {
      return (armour['images'] as Map<String, dynamic>).keys.first;
    }
    return null;
  }

  bool isValid() {
    return armour['name'].toString().trim().isNotEmpty &&
        armour['description'].toString().trim().isNotEmpty &&
        getFirstImageName()?.isNotEmpty == true;
  }

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder:
        (_) => StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                backgroundColor: Colors.black,
                title: Text(
                  'Edit Armour: ${armour['name'] ?? 'New Armour'}',
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
                          onChanged: (val) => armour['name'] = val,
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
                          onChanged: (val) => armour['description'] = val,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if ((armour['preview'] ?? '').isNotEmpty ||
                            getFirstImageName() != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                armour['preview']?.isNotEmpty == true
                                    ? armour['preview']
                                    : 'https://raw.githubusercontent.com/WatchAndShootUK/_afvr_lib/main/${getFirstImageName()}',
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
                                getFirstImageName() ?? '',
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
                                  armour['name'] ?? 'armour',
                                );
                                armour['images'] = {newName: armour['name']};
                                armour['preview'] = previewUrl;
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
                    onPressed: () {
                      if (isValid()) {
                        itemSaveService(context,armour,armours, 'armour.json');
                      } else {
                        final List<String> errors = [];
                        if (armour['name'].toString().trim().isEmpty) {
                          errors.add("Name is required.");
                        }
                        if (armour['description'].toString().trim().isEmpty) {
                          errors.add("Description is required.");
                        }
                        if (getFirstImageName() == null) {
                          errors.add("At least one image is required.");
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
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        ),
  );
}
