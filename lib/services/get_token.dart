import 'package:http/http.dart' as http;

Future<String> fetchGitHubToken() async {
  const url = 'https://script.google.com/macros/s/AKfycbwnAcSD5TokGZKhQkBSjV5fjH879NLCi65CjNNMyY4oDVpnjswKkDklP3-NXJ5NAzveKA/exec?secret=qwerty123';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return response.body.trim();
  } else {
    return ''; // fallback to non-null value
  }
}
