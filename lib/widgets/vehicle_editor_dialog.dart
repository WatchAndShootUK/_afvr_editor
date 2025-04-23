// THIS ONE WORKS
// lib/widgets/vehicle_editor_dialog.dart

// ignore_for_file: unused_import, deprecated_member_use, avoid_web_libraries_in_flutter, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'dart:html' as html;
import 'dart:convert';
import 'package:afvr_editor/globals.dart';
import 'package:afvr_editor/main.dart';
import 'package:afvr_editor/services/github_write_service.dart';
import 'package:afvr_editor/services/github_upload_service.dart';
import 'package:afvr_editor/widgets/item_picker.dart';
import 'package:afvr_editor/widgets/type_picker.dart';
import 'package:afvr_editor/widgets/vehicle_splitter.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:afvr_editor/utils/proper_case.dart';

Future<Map<String, dynamic>?> showEditorDialog(
  BuildContext context,
  Map<String, dynamic> originalVehicle,
) {
  final uuid = const Uuid();

  final Map<String, dynamic> vehicle =
      originalVehicle.isEmpty
          ? {
            'uid': uuid.v4(),
            'name': '',
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
            'dimensions': {
              'height': '',
              'length': '',
              'weight': '',
              'width': '',
            },
            'engine': {
              'amphibious': '',
              'fuel': '',
              'horsepower': '',
              'max_speed': '',
              'range': '',
            },
            'other_data': {},
          }
          : json.decode(json.encode(originalVehicle));

  vehicle['sensors'] ??= [];
  vehicle['armament'] ??= [];
  vehicle['protection'] ??= [];

  final orderedKeys = [
    'name',
    'family',
    'crew',
    'status',
    'description',
    'types',
    'armament',
    'protection',
    'sensors',
    'images',
    'recognising_features',
    'about',
    'dimensions',
    'engine',
  ];

  final readOnlyKeys = {'status'};
  const double paddingSize = 10;

  String sanitizeFileName(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String generateUID(String baseName) {
    final randomId = uuid.v4().replaceAll('-', '').substring(0, 20);
    return '${sanitizeFileName(baseName)}_$randomId.jpg';
  }

  List<String> isValid(Map<String, dynamic> vehicle) {
    List<String> returnErrors = [];

    bool isNonEmpty(value) {
      if (value == null) return false;
      if (value is String) return value.trim().isNotEmpty;
      if (value is List) return value.isNotEmpty && value.every(isNonEmpty);
      if (value is Map) {
        return value.isNotEmpty && value.values.every(isNonEmpty);
      }
      return true;
    }

    // Required top-level keys
    final requiredTopLevelKeys = [
      'uid',
      'name',
      'crew',
      'description',
      'types',
      'images',
      'recognising_features',
      'about',
      'dimensions',
      'engine',
    ];

    for (final key in requiredTopLevelKeys) {
      if (!vehicle.containsKey(key)) returnErrors.add('Missing field: $key');
      if (!isNonEmpty(vehicle[key])) {
        returnErrors.add('Field "$key" cannot be empty');
      }
    }

    // Validate nested maps
    final nestedMapFields = {
      'about': [
        'alliance',
        'in_service_date',
        'manufacturer',
        'operators',
        'origin_country',
        'out_service_date',
      ],
      'dimensions': ['height', 'length', 'weight', 'width'],
      'engine': ['amphibious', 'fuel', 'horsepower', 'max_speed', 'range'],
    };

    for (final entry in nestedMapFields.entries) {
      final map = vehicle[entry.key];
      if (map is! Map) returnErrors.add('"${entry.key}" must be a map');
      for (final field in entry.value) {
        if (!map.containsKey(field) || !isNonEmpty(map[field])) {
          returnErrors.add('Field "${entry.key}.$field" cannot be empty');
        }
      }
    }

    return returnErrors; // valid!
  }

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder:
        (_) => StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                backgroundColor: Colors.black,
                title: Text(
                  'Edit: ${vehicle['name'] ?? 'Vehicle'}',
                  style: const TextStyle(color: Colors.white),
                ),
                content: SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(paddingSize),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            orderedKeys.expand((key) {
                              final value = vehicle[key];
                              final isReadOnly = readOnlyKeys.contains(key);
                              final properKey = properCase(
                                key.replaceAll('_', ' '),
                              );

                              List<Widget> section = [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (properKey != 'Name')
                                      SizedBox(height: 10),
                                    if (properKey != 'Name')
                                      Container(
                                        height: 2,
                                        width: double.infinity,
                                        color: wasdColour,
                                      ),
                                    SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: paddingSize / 2,
                                      ),
                                      child: Text(
                                        properKey,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ];

                              if (value is String ||
                                  value is num ||
                                  value is bool) {
                                final controller = TextEditingController(
                                  text: value.toString(),
                                );
                                final isEmpty = value.toString().trim().isEmpty;

                                section.add(
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: paddingSize,
                                    ),
                                    child: SizedBox(
                                      width:
                                          properKey == 'Name' ||
                                                  properKey == 'Family'
                                              ? 200
                                              : double.infinity,
                                      child: TextField(
                                        maxLength:
                                            properKey == 'Name' ||
                                                    properKey == 'Family'
                                                ? 20
                                                : null,
                                        controller: controller,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: properKey,
                                          labelStyle: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          filled: true,
                                          fillColor:
                                              isEmpty
                                                  ? Colors.yellow[700]
                                                  : Colors.grey[850],
                                          border: const OutlineInputBorder(),
                                        ),
                                        onChanged:
                                            isReadOnly
                                                ? null
                                                : (text) => vehicle[key] = text,
                                        readOnly: isReadOnly,
                                        maxLines:
                                            key == 'description' ? null : 1,
                                        minLines: key == 'description' ? 3 : 1,
                                      ),
                                    ),
                                  ),
                                );
                              } else if (value is List) {
                                section.addAll(
                                  value.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    final isMapWithPreview =
                                        item is Map &&
                                        item.containsKey('preview');
                                    final itemName =
                                        isMapWithPreview
                                            ? item['name']
                                            : item.toString();
                                    final previewUrl =
                                        isMapWithPreview
                                            ? item['preview']
                                            : null;

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: paddingSize / 2,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (key == 'images' &&
                                              itemName.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: paddingSize / 2,
                                              ),
                                              child: Image.network(
                                                previewUrl ??
                                                    'https://raw.githubusercontent.com/WatchAndShootUK/_afvr_lib/main/$itemName',
                                                height: 150,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, _) =>
                                                        const Text(
                                                          'Image load failed',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                              ),
                                            ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 8.0,
                                                      ),
                                                  child: Text(
                                                    itemName,
                                                    style: TextStyle(
                                                      color:
                                                          key == 'images'
                                                              ? Colors.white
                                                              : Color(
                                                                0xFF958B60,
                                                              ),
                                                      fontStyle:
                                                          key == 'images'
                                                              ? FontStyle.italic
                                                              : FontStyle
                                                                  .normal,
                                                      fontWeight:
                                                          key == 'images'
                                                              ? FontWeight
                                                                  .normal
                                                              : FontWeight.bold,
                                                      fontSize:
                                                          key == 'images'
                                                              ? 15
                                                              : 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed:
                                                    () => setState(
                                                      () =>
                                                          value.removeAt(index),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                );

                                section.add(
                                  TextButton.icon(
                                    onPressed: () async {
                                      if (key == 'types') {
                                        // Types Picker
                                        final selected = await showTypePicker(
                                          context,
                                          vehicle,
                                        );
                                        if (selected != null &&
                                            !value.contains(selected)) {
                                          setState(() => value.add(selected));
                                        }
                                      } else if (key == 'images') {
                                        final upload = // Image Picker
                                            html.FileUploadInputElement();
                                        upload.accept = 'image/*';
                                        upload.click();
                                        await upload.onChange.first;
                                        final files = upload.files;
                                        if (files != null && files.isNotEmpty) {
                                          final reader = html.FileReader();
                                          reader.readAsDataUrl(files.first);
                                          reader.onLoadEnd.listen((_) {
                                            final previewUrl =
                                                reader.result as String;
                                            final newName = generateUID(
                                              vehicle['name'],
                                            );
                                            setState(
                                              () => value.add({
                                                'name': newName,
                                                'preview': previewUrl,
                                              }),
                                            );
                                          });
                                        }
                                      } else if (key == 'armament') {
                                        final selected = await showItemPicker(
                                          context: context,
                                          title: 'Select Weapon',
                                          items: weapons,
                                          vehicle: vehicle,
                                          filterKey: 'armament',
                                        );
                                        if (selected != null &&
                                            !value.contains(selected)) {
                                          setState(() => value.add(selected));
                                        }
                                      } else if (key == 'protection') {
                                        final selected = await showItemPicker(
                                          context: context,
                                          title: 'Select Armour',
                                          items: armours,
                                          vehicle: vehicle,
                                          filterKey: 'protection',
                                        );
                                        if (selected != null &&
                                            !value.contains(selected)) {
                                          setState(() => value.add(selected));
                                        }
                                      } else if (key == 'sensors') {
                                        final selected = await showItemPicker(
                                          context: context,
                                          title: 'Select Sensor',
                                          items: sensors,
                                          vehicle: vehicle,
                                          filterKey: 'sensors',
                                        );
                                        if (selected != null &&
                                            !value.contains(selected)) {
                                          setState(() => value.add(selected));
                                        }
                                      } else {
                                        setState(() => value.add(''));
                                      }
                                    },
                                    icon: const Icon(Icons.add),
                                    label: Text(
                                      key == 'images'
                                          ? 'Add image'
                                          : key == 'types'
                                          ? 'Add new type'
                                          : key == 'armament'
                                          ? 'Add weapon'
                                          : key == 'protection'
                                          ? 'Add protection'
                                          : key == 'sensors'
                                          ? 'Add sensor'
                                          : 'Add item',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              } else if (value is Map) {
                                final isRecognising =
                                    key == 'recognising_features';

                                section.addAll(
                                  value.entries.map((e) {
                                    final val = e.value;
                                    final valueText =
                                        val is String
                                            ? val
                                            : val is Map && val[''] is String
                                            ? val['']
                                            : '';
                                    final preview =
                                        val is Map ? val['preview'] : null;

                                    final valueController =
                                        TextEditingController(text: valueText);
                                    final isEmpty = valueText.trim().isEmpty;

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: paddingSize / 2,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          if (vehicle['recognising_features'] !=
                                                  null &&
                                              vehicle['recognising_features']
                                                  .isNotEmpty &&
                                              e.key !=
                                                  vehicle['recognising_features']
                                                      .keys
                                                      .first)
                                            SizedBox(height: 20),
                                          if (isRecognising && e.key.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 6,
                                              ),
                                              child: Image.network(
                                                preview ??
                                                    'https://raw.githubusercontent.com/WatchAndShootUK/_afvr_lib/main/${e.key}',
                                                height: 150,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (_, __, ___) => const Text(
                                                      'Image load failed',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          if (isRecognising)
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 8.0,
                                                        ),
                                                    child: Text(
                                                      e.key,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          Row(
                                            children: [
                                              if (isRecognising)
                                                const SizedBox(width: 8),
                                              Expanded(
                                                flex: isRecognising ? 4 : 1,
                                                child: TextField(
                                                  controller: valueController,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        isRecognising
                                                            ? 'Description'
                                                            : properCase(
                                                              e.key
                                                                  .toString()
                                                                  .replaceAll(
                                                                    '_',
                                                                    ' ',
                                                                  ),
                                                            ),
                                                    labelStyle: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        isEmpty
                                                            ? Colors.yellow[700]
                                                            : Colors.grey[850],
                                                    border:
                                                        const OutlineInputBorder(),
                                                  ),
                                                  readOnly: isReadOnly,
                                                  maxLines:
                                                      isRecognising ? null : 1,
                                                  minLines:
                                                      isRecognising ? 3 : 1,
                                                  onChanged:
                                                      isReadOnly
                                                          ? null
                                                          : (text) =>
                                                              value[e.key] =
                                                                  text,
                                                ),
                                              ),
                                              if (![
                                                'about',
                                                'dimensions',
                                                'engine',
                                              ].contains(key))
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed:
                                                      () => setState(
                                                        () =>
                                                            value.remove(e.key),
                                                      ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                                if ([
                                  'recognising_features',
                                  'other_data',
                                ].contains(key)) {
                                  section.add(
                                    TextButton.icon(
                                      onPressed: () async {
                                        if (key == 'recognising_features') {
                                          final upload =
                                              html.FileUploadInputElement();
                                          upload.accept = 'image/*';
                                          upload.click();
                                          await upload.onChange.first;
                                          final files = upload.files;
                                          if (files != null &&
                                              files.isNotEmpty) {
                                            final reader = html.FileReader();
                                            reader.readAsDataUrl(files.first);
                                            reader.onLoadEnd.listen((_) {
                                              final previewUrl =
                                                  reader.result as String;
                                              final newName = generateUID(
                                                vehicle['name'],
                                              );
                                              value[newName] = {
                                                'preview': previewUrl,
                                                '': '',
                                              };
                                              setState(() {});
                                            });
                                          }
                                        } else {
                                          setState(() {
                                            int counter = 1;
                                            String newKey;

                                            do {
                                              newKey = 'Other Data [$counter]';
                                              counter++;
                                            } while (value.containsKey(newKey));

                                            value[newKey] = '';
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.add),
                                      label: Text(
                                        key == 'recognising_features'
                                            ? "Add recognising feature"
                                            : "Add item",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              }

                              return section;
                            }).toList(),
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      final errors = isValid(vehicle);
                      if (errors.isEmpty) {
                        vehicle['status'] = 'complete';
                      } else {
                        vehicle['status'] = 'draft';
                      }
                      String uploadCode = '';
                      // Normalize recognising_features and images before returning
                      final features = vehicle['recognising_features'];
                      if (features is Map) {
                        final cleanMap = <String, String>{};
                        for (var entry in features.entries) {
                          if (entry.value is String) {
                            cleanMap[entry.key] = entry.value;
                          } else if (entry.value is Map &&
                              entry.value[''] is String) {
                            cleanMap[entry.key] = entry.value[''];

                            // IMAGE UPLOADED
                            uploadCode = await uploadImageToGitHub(
                              base64Image: entry.value['preview'],
                              fileName: entry.key,
                            );
                          }
                        }
                        vehicle['recognising_features'] = cleanMap;
                      }

                      int i = 0;
                      List<String> cleanedImages = [];
                      for (var image in vehicle['images']) {
                        if (image is String) {
                          cleanedImages.add(image);
                        } else {
                          // It's an image preview - upload it!
                          uploadCode = await uploadImageToGitHub(
                            base64Image: image['preview'],
                            fileName: image['name'],
                          );

                          cleanedImages.add(image['name']);
                        }
                        i = i + 1;
                      }
                      vehicle['images'] = cleanedImages;

                      final isNew =
                          !vehicles.any((a) => a['uid'] == vehicle['uid']);
                      if (isNew) {
                        // new item
                        vehicles.add(vehicle);
                        vehicles.sort(
                          (a, b) => a['name'].toString().compareTo(
                            b['name'].toString(),
                          ),
                        );
                      } else {
                        // updated item
                        final index = vehicles.indexWhere(
                          (w) => w['uid'] == vehicle['uid'],
                        );
                        vehicles[index] = vehicle;
                      }

                      splitAndWriteJsonList(vehicles, 'vehicles', isNew);

                      scaffoldMessengerKey.currentState?.showSnackBar(
                        SnackBar(
                          content: Text(
                            isNew
                                ? vehicle['name'] +
                                    ' added! ' +
                                    (errors.isNotEmpty
                                        ? '\nSaved as draft:\n- ${errors.join('\n- ')}'
                                        : '\nSaved as complete') +
                                    uploadCode
                                : vehicle['name'] +
                                    ' updated! ' +
                                    (errors.isNotEmpty
                                        ? '\nSaved as draft:\n- ${errors.join('\n- ')}'
                                        : '\nSaved as complete') +
                                    uploadCode,
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor:
                              errors.isEmpty
                                  ? Colors.green[700]
                                  : Colors.red[700],
                        ),
                      );

                      Navigator.pop(context, vehicle);
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
