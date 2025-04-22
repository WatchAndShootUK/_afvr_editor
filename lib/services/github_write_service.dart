import 'dart:convert';
import 'package:afvr_editor/services/version_control_service.dart';
import 'package:http/http.dart' as http;

/// Writes a list of maps to GitHub by converting to a UID-keyed map.
/// It fetches the file's SHA, prints it, and then updates or creates the file.
Future<void> githubWrite(
  List<Map<String, dynamic>> inputData,
  String fileName,
  bool isNew
) async {
  const String repoOwner = 'WatchAndShootUK';
  const String repoName = '_afvr_lib_secure';
  const String token = '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';

  final url = Uri.parse(
    'https://api.github.com/repos/$repoOwner/$repoName/contents/$fileName?ref=main',
  );

  print(url);
  // Step 1: Convert list to map using 'uid' as key
  final Map<String, dynamic> jsonData = {
    for (final item in inputData) item['uid'].toString(): item,
  };

  String? sha;
  final shaResponse = await http.get(
    url,
    headers: {
      'Authorization': 'token $token',
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'FlutterApp',
    },
  );

  if (shaResponse.statusCode == 200) {
    final decodedShaResponse = json.decode(shaResponse.body);
    sha = decodedShaResponse['sha'];
    print('✅ SHA for $fileName: $sha');
  } else if (shaResponse.statusCode == 404) {
    print('📁 $fileName does not exist — will create new file.');
  } else {
    throw Exception(
      '❌ Failed to get SHA: ${shaResponse.statusCode} ${shaResponse.body}',
    );
  }

  final encodedContent = base64Encode(utf8.encode(jsonEncode(jsonData)));

  final payload = jsonEncode({
    'message': sha == null
        ? 'Create $fileName from Flutter WebApp'
        : 'Update $fileName from Flutter WebApp',
    'content': encodedContent,
    if (sha != null) 'sha': sha,
  });

  final writeResponse = await http.put(
    url,
    headers: {
      'Authorization': 'token $token',
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'FlutterApp',
    },
    body: payload,
  );

  if (writeResponse.statusCode == 200 || writeResponse.statusCode == 201) {
    print('✅ Successfully wrote $fileName');
    updateVersionFile(isNew);
  } else {
    print('❌ Failed to write $fileName: ${writeResponse.statusCode} ${writeResponse.body}');
  }
}