import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> uploadImageToGitHub({
  required String base64Image,
  required String fileName,
  
}) async {
  final owner = 'WatchAndShootUK';
  final repo = '_afvr_lib';
  final branch = 'main';
  final githubToken ='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';

  final url =
      'https://api.github.com/repos/$owner/$repo/contents/$fileName';

  final body = jsonEncode({
    'message': 'Upload $fileName',
    'content': base64Image.split(',').last, // Remove data:... prefix
    'branch': branch,
  });

  final response = await http.put(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $githubToken',
      'Accept': 'application/vnd.github+json',
    },
    body: body,
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    return '\n✅ Image upload successful: $fileName';
  } else {
    return '\n❌ Upload failed: ${response.statusCode}';
  }
}