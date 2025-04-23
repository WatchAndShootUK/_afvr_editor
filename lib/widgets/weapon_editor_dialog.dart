// lib/widgets/weapon_editor_dialog.dart

// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:convert';

import 'package:afvr_editor/globals.dart';
import 'package:afvr_editor/services/item_save_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;

Future<Map<String, dynamic>?> showWeaponEditorDialog(
  BuildContext context,
  Map<String, dynamic> originalWeapon,
) {
  final uuid = const Uuid();

  final weapon =
      originalWeapon.isEmpty
          ? {
            'uid': uuid.v4(),
            'name': '',
            'descriptor': '',
            'calibre': '',
            'description': '',
            'image': '',
            'preview': '',
            'ammunition': {},
          }
          : json.decode(json.encode(originalWeapon)) as Map<String, dynamic>;

  const paddingSize = 10.0;

  final nameController = TextEditingController(text: weapon['name']);
  final descriptorController = TextEditingController(
    text: weapon['descriptor'],
  );
  final calibreController = TextEditingController(text: weapon['calibre']);
  final descriptionController = TextEditingController(
    text: weapon['description'],
  );

  final Map<String, TextEditingController> ammoTypeControllers = {};
  final Map<String, TextEditingController> ammoRangeControllers = {};
  weapon['ammunition'].forEach((key, value) {
    ammoTypeControllers[key] = TextEditingController(text: key);
    ammoRangeControllers[key] = TextEditingController(text: value);
  });

  String generateUID(String baseName) {
    final randomId = uuid.v4().replaceAll('-', '').substring(0, 20);
    return '${baseName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}_$randomId.jpg';
  }

  bool isValid() {
    final requiredFields = [
      'name',
      'descriptor',
      'calibre',
      'description',
      'image',
    ];
    for (final field in requiredFields) {
      if ((weapon[field] ?? '').toString().trim().isEmpty) return false;
    }
    for (final entry in weapon['ammunition'].entries) {
      final type = entry.key.toString().trim();
      final range = entry.value.toString().trim();
      if (type.isEmpty || range.isEmpty) return false;
    }
    return true;
  }

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder:
        (_) => StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                backgroundColor: Colors.black,
                title: Text(
                  'Edit Weapon: ${weapon['name'] ?? 'New Weapon'}',
                  style: const TextStyle(color: Colors.white),
                ),
                content: SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(paddingSize),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: paddingSize),
                            child: TextField(
                              controller: nameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'name',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor:
                                    nameController.text.trim().isEmpty
                                        ? Colors.yellow[700]
                                        : Colors.grey[850],
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (val) => weapon['name'] = val,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: paddingSize),
                            child: TextField(
                              controller: descriptorController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'descriptor',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor:
                                    descriptorController.text.trim().isEmpty
                                        ? Colors.yellow[700]
                                        : Colors.grey[850],
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (val) => weapon['descriptor'] = val,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: paddingSize),
                            child: TextField(
                              controller: calibreController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'calibre',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor:
                                    calibreController.text.trim().isEmpty
                                        ? Colors.yellow[700]
                                        : Colors.grey[850],
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (val) => weapon['calibre'] = val,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: paddingSize),
                            child: TextField(
                              controller: descriptionController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'description',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor:
                                    descriptionController.text.trim().isEmpty
                                        ? Colors.yellow[700]
                                        : Colors.grey[850],
                                border: const OutlineInputBorder(),
                              ),
                              maxLines: null,
                              minLines: 3,
                              onChanged: (val) => weapon['description'] = val,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Image',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if ((weapon['preview'] ?? '').isNotEmpty ||
                              (weapon['image'] ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    weapon['preview']?.isNotEmpty == true
                                        ? weapon['preview']
                                        : 'https://raw.githubusercontent.com/WatchAndShootUK/_afvr_lib/main/${weapon['image']}',
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
                                    weapon['image'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                    weapon['name'] ?? 'weapon',
                                  );
                                  weapon['image'] = newName;
                                  weapon['preview'] = previewUrl;
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

                          const SizedBox(height: 10),
                          const Text(
                            'Ammunition Ranges',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          ...weapon['ammunition'].keys.toList().map<Widget>((
                            ammoType,
                          ) {
                            final typeController =
                                ammoTypeControllers[ammoType]!;
                            final rangeController =
                                ammoRangeControllers[ammoType]!;
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: paddingSize / 2,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: typeController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Type',
                                        filled: true,
                                        fillColor:
                                            typeController.text.trim().isEmpty
                                                ? Colors.yellow[700]
                                                : Colors.grey,
                                        border: const OutlineInputBorder(),
                                      ),
                                      onChanged: (val) {
                                        if (val != ammoType) {
                                          final existing =
                                              weapon['ammunition'][ammoType];
                                          weapon['ammunition'].remove(ammoType);
                                          weapon['ammunition'][val] = existing;
                                          ammoTypeControllers[val] =
                                              typeController;
                                          ammoRangeControllers[val] =
                                              rangeController;
                                          (context as Element).markNeedsBuild();
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: rangeController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Range',
                                        filled: true,
                                        fillColor:
                                            weapon['ammunition'][ammoType]
                                                    .toString()
                                                    .trim()
                                                    .isEmpty
                                                ? Colors.yellow[700]
                                                : Colors.grey,
                                        border: const OutlineInputBorder(),
                                      ),
                                      onChanged: (val) {
                                        weapon['ammunition'][ammoType] = val;
                                        (context as Element).markNeedsBuild();
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      weapon['ammunition'].remove(ammoType);
                                      (context as Element).markNeedsBuild();
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                          TextButton.icon(
                            onPressed: () {
                              int counter = 1;
                              String newKey;
                              do {
                                newKey = 'Ammunition $counter';
                                counter++;
                              } while (weapon['ammunition'].containsKey(
                                newKey,
                              ));
                              weapon['ammunition'][newKey] = '';
                              ammoTypeControllers[newKey] =
                                  TextEditingController(text: newKey);
                              ammoRangeControllers[newKey] =
                                  TextEditingController();
                              (context as Element).markNeedsBuild();
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Add Ammunition Type',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
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
                          weapon,
                          weapons,
                          'weapons.json',
                        );
                      } else {
                        final List<String> errors = [];
                        if (weapon['name'].toString().trim().isEmpty) {
                          errors.add("Name is required.");
                        }
                        if (weapon['descriptor'].toString().trim().isEmpty) {
                          errors.add("Descriptor is required.");
                        }
                        if (weapon['calibre'].toString().trim().isEmpty) {
                          errors.add("Calibre is required.");
                        }
                        if (weapon['description'].toString().trim().isEmpty) {
                          errors.add("Description is required.");
                        }
                        if (weapon['image'].toString().trim().isEmpty) {
                          errors.add("Image is required.");
                        }
                        for (var entry in weapon['ammunition'].entries) {
                          final key = entry.key.trim();
                          final val = entry.value.toString().trim();
                          if (key.isEmpty || val.isEmpty) {
                            errors.add(
                              "Ammunition type and range must be filled.",
                            );
                            break;
                          }
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
