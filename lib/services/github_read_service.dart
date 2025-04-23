import 'dart:convert';
import 'package:afvr_editor/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<void> githubRead(
  String filename,
  List<Map<String, dynamic>> targetList,
) async {
  const String repoOwner = 'WatchAndShootUK';
  const String repoName = '_afvr_lib_secure';

  if (filename == 'vehicles.json') {
    final contentsUrl = Uri.parse(
      'https://api.github.com/repos/$repoOwner/$repoName/contents',
    );

    final contentsResponse = await http.get(
      contentsUrl,
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (contentsResponse.statusCode != 200) {
      throw Exception(
        '❌ Failed to list repo contents: ${contentsResponse.body}',
      );
    }

    final List<dynamic> files = json.decode(contentsResponse.body);
    final List<String> vehicleFiles =
        files
            .where(
              (file) =>
                  file['name'].toString().startsWith('vehicles_') &&
                  file['name'].toString().endsWith('.json'),
            )
            .map<String>((file) => file['name'].toString())
            .toList();

    targetList.clear();
    if (kDebugMode) {
      print(vehicleFiles);
    }
    for (final partFile in vehicleFiles) {
      final partUrl = Uri.parse(
        'https://api.github.com/repos/$repoOwner/$repoName/contents/$partFile',
      );

      final response = await http.get(
        partUrl,
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3.raw',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> raw = json.decode(response.body);

        targetList.addAll(
          raw.entries.map((e) {
            final item = Map<String, dynamic>.from(e.value);
            item['uid'] = e.key;
            return item;
          }),
        );
      } else {
        throw Exception('❌ Failed to read $partFile: ${response.body}');
      }
    }
  } else {
    final url = Uri.parse(
      'https://api.github.com/repos/$repoOwner/$repoName/contents/$filename',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3.raw',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> raw = json.decode(response.body);

      targetList.clear();
      targetList.addAll(
        raw.entries.map((e) {
          final item = Map<String, dynamic>.from(e.value);
          item['uid'] = e.key;
          return item;
        }),
      );
    } else {
      throw Exception('❌ Failed to read $filename: ${response.body}');
    }
  }
}
