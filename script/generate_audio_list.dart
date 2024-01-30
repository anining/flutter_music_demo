import 'dart:io';
import 'dart:convert';

void main() {
  generateAudioList();
}

void generateAudioList() {
  Directory audioDir = Directory('assets/audio');
  List<FileSystemEntity> fileList =
      audioDir.listSync(recursive: true, followLinks: true);
  List<Map<String, String>> audioList = fileList
      .whereType<File>()
      .map((file) => ({
            'path': file.path.substring(7),
            'name': file.uri.pathSegments.last,
          }))
      .toList();
  String jsonString = jsonEncode(audioList);
  File outputFile = File('json/generate_audio_list.json');
  outputFile.writeAsStringSync(jsonString);
}
