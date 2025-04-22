// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:afvr_editor/services/github_write_service.dart';
import 'package:afvr_editor/services/github_upload_service.dart';
import 'package:flutter/material.dart';

itemSaveService(
  BuildContext context,
  Map<String, dynamic> item,
  List<Map<String, dynamic>> globalList,
  String fileName
) async {

  // This section checks to see if an image has been uploaded and sends it to gitHub.
  String uploadCode = '';
  if (item['preview'] is String &&
      item['preview'].toString().trim().isNotEmpty) {
    uploadCode = await uploadImageToGitHub(
      base64Image: item['preview'],
      fileName:
          item['image'] is String
              ? item['image']
              : (item['images'] is Map && item['images'].isNotEmpty
                  ? item['images'].keys.first
                  : null),
    );

    item.remove('preview');
  }

  // This section saves to the relevant List<Map<String, dynamic>>.
  bool isNew = false;

  final index = globalList.indexWhere((w) => w['uid'] == item['uid']);
  if (index >= 0) {
    // Update existing item
    globalList[index] = item;
  } else {
    // Add new item
    isNew = true;
    globalList.add(item);
    globalList.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
  }

  githubWrite(globalList, fileName, isNew);

  // Success message
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNew
              ? item['name'] + ' added!' + uploadCode
              : item['name'] + ' updated!' + uploadCode,
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green[700],
      ),
    );
  });

  Navigator.pop(context, item);
}
