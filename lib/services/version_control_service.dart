import 'dart:convert';
import 'package:afvr_editor/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<void> updateVersionFile(bool isNew, String fileName) async {
  const String repoOwner = 'WatchAndShootUK';
  const String repoName = '_afvr_lib_secure';

  // Only update version if file is version-tracked
  const versionedFiles = [
    'vehicles_1.json',
    'armour.json',
    'weapons.json',
    'sensors.json',
  ];
  if (!versionedFiles.contains(fileName)) {
    if (kDebugMode) print('ℹ️ Skipping version update for $fileName');
    return;
  }

  // Step 1: Build the GitHub URL for version.json
  final versionUrl = Uri.parse(
    'https://api.github.com/repos/$repoOwner/$repoName/contents/version.json?ref=main',
  );

  // Step 2: Download the current version.json file
  final versionResponse = await http.get(
    versionUrl,
    headers: {
      'Authorization': 'token $token',
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'FlutterApp',
    },
  );

  if (versionResponse.statusCode != 200) {
    if (kDebugMode) {
      print(
        '❌ Failed to fetch version.json: ${versionResponse.statusCode} ${versionResponse.body}',
      );
    }
    return;
  }

  final versionData = json.decode(versionResponse.body);
  final String? sha = versionData['sha'];
  final String? encoded = versionData['content'];

  // Step 3: Validate and decode the content
  if (sha == null || encoded == null) {
    if (kDebugMode) print('❌ Missing "sha" or "content" from GitHub response');
    return;
  }

  if (kDebugMode) print('📦 Current SHA for version.json: $sha');

  final decodedContent = utf8.decode(
    base64Decode(encoded.replaceAll('\n', '')),
  );
  Map<String, dynamic> versionJson = json.decode(decodedContent);

  // Step 4: Modify the version data
  if (isNew) {
    final oldMajor = versionJson['major_version'] ?? 0;
    versionJson['major_version'] = oldMajor + 1;
    versionJson['minor_version'] = 0; // Reset minor version.
    if (kDebugMode)
      print(
        '🔢 Major version incremented: $oldMajor → ${versionJson['major_version']}',
      );
  } else {
    final oldMinor = versionJson['minor_version'] ?? 0;
    versionJson['minor_version'] = oldMinor + 1;
    if (kDebugMode)
      print(
        '🔢 Minor version incremented: $oldMinor → ${versionJson['minor_version']}',
      );
  }
  version.value = getVersionCodeString(versionJson);

  versionJson['last_updated'] = DateFormat(
    "yyyy-MM-dd'T'HH:mm:ss'Z'",
  ).format(DateTime.now().toUtc());

  // Step 5: Encode and prepare payload for update
  final updatePayload = jsonEncode({
    'message': 'Update version.json from Flutter WebApp',
    'content': base64Encode(utf8.encode(jsonEncode(versionJson))),
    'sha': sha,
  });

  // Step 6: Upload the updated version.json using PUT
  final updateResponse = await http.put(
    versionUrl,
    headers: {
      'Authorization': 'token $token',
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'FlutterApp',
    },
    body: updatePayload,
  );

  // Step 7: Handle the result
  if (updateResponse.statusCode == 200 || updateResponse.statusCode == 201) {
    if (kDebugMode) print('✅ version.json updated successfully.');
  } else {
    if (kDebugMode) {
      print(
        '❌ Failed to update version.json: ${updateResponse.statusCode} ${updateResponse.body}',
      );
    }
  }
}

String getVersionCodeString(Map<String, dynamic> input) {
  return '${input['build_version']}.${input['major_version']}.${input['minor_version']}';}