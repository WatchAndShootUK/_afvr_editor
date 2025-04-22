import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<void> updateVersionFile(bool isNew) async {
  const String repoOwner = 'WatchAndShootUK';
  const String repoName = '_afvr_lib_secure';
  const String token = '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';

  final versionUrl = Uri.parse(
    'https://api.github.com/repos/$repoOwner/$repoName/contents/version.json',
  );

  final versionResponse = await http.get(
    versionUrl,
    headers: {
      'Authorization': 'token $token',
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'FlutterApp',
    },
  );

  if (versionResponse.statusCode == 200) {
    final versionData = json.decode(versionResponse.body);
    final versionSha = versionData['sha'];
    final encoded = versionData['content'];

    final cleanBase64 = encoded.replaceAll('\n', '');
    final decoded = utf8.decode(base64Decode(cleanBase64));

    Map<String, dynamic> versionJson = {};
    versionJson = json.decode(decoded);

    if (isNew) {
      final int oldMajor = versionJson['minor_version'] ?? 0;
      final int newMajor = oldMajor + 1;
      versionJson['major_version'] = newMajor;
      print('🔢 Major version: $oldMajor → $newMajor');
    } else {
      final int oldMinor = versionJson['minor_version'] ?? 0;
      final int newMinor = oldMinor + 1;
      versionJson['minor_version'] = newMinor;
      print('🔢 Minor version: $oldMinor → $newMinor');
    }

    final String dtg = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss'Z'",
    ).format(DateTime.now().toUtc());
    versionJson['last_updated'] = dtg;

    final updatePayload = jsonEncode({
      'message': 'Increment version',
      'content': base64Encode(utf8.encode(jsonEncode(versionJson))),
      'sha': versionSha,
    });

    final versionWrite = await http.put(
      versionUrl,
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'FlutterApp',
      },
      body: updatePayload,
    );

    if (versionWrite.statusCode == 200 || versionWrite.statusCode == 201) {
      print('✅ Version file updated');
    } else {
      print(
        '❌ Failed to update version file: ${versionWrite.statusCode} ${versionWrite.body}',
      );
    }
  } else {
    print(
      '❌ Failed to read version file: ${versionResponse.statusCode} ${versionResponse.body}',
    );
  }
}
