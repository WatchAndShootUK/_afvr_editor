import 'dart:convert';
import 'package:afvr_editor/services/github_write_service.dart';

Future<void> splitAndWriteJsonList(
  List<Map<String, dynamic>> inputList,
  String baseFileName,
  bool isNew
) async {
  final int maxBytes = 400 * 1024;

  List<List<Map<String, dynamic>>> chunks = [];
  List<Map<String, dynamic>> currentChunk = [];
  int currentSize = 0;

  for (final item in inputList) {
    final jsonSize = utf8.encode(json.encode(item)).length;

    if (currentSize + jsonSize > maxBytes && currentChunk.isNotEmpty) {
      chunks.add(List.from(currentChunk));
      currentChunk.clear();
      currentSize = 0;
    }

    currentChunk.add(item);
    currentSize += jsonSize;
  }

  if (currentChunk.isNotEmpty) {
    chunks.add(currentChunk);
  }
  for (int i = 0; i < chunks.length; i++) {
    final chunk = chunks[i];
    final fileName = '${baseFileName}_${i + 1}.json';
    await githubWrite(chunk, fileName, isNew);
    if (isNew) {isNew = false;}
  }
}