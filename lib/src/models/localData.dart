import 'package:surah_schedular/src/models/formInputs.dart';
import 'package:surah_schedular/src/models/adhan.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class LocalData {

  LocalData();

  Future<Map<String, dynamic>> readJsonFile(String path) async {
    // Specify the path to your JSON file
    String filePath = '$path/surah_scheduler.json';

    try {
      File file = File(filePath);
      if (await file.exists()) {
        // Read the JSON file
        String contents = await file.readAsString();

        // Parse the JSON content
        Map<String, dynamic> jsonData = jsonDecode(contents);
        return jsonData;
      } else {
        return {};
      }
    } catch (e) {
      print('Error reading JSON file: $e');
      return {};
    }

    return {};
  }

  Future<void> saveInfo(String path, FormInputs formInputs, AdhanItem adhanItem, List<String> tasks, List azaanVolumes, var castDevice, String calledFrom) async {
    try {
      Map<String, dynamic> jsonData = await readJsonFile(path);

      if (calledFrom == 'home') jsonData['home'] = formInputs.toString();
      if (calledFrom == 'settings') jsonData['selectedAdhan'] = adhanItem;
      if (calledFrom == 'schedular') jsonData['tasks'] = tasks;
      if (calledFrom == 'settings') jsonData['azaanVolumes'] = azaanVolumes;
      if (calledFrom == 'cast') jsonData['castDevice'] = castDevice;

      // Specify the file path
      String filePath = '$path/surah_scheduler.json';

      // Convert JSON data to a string
      String jsonString = jsonEncode(jsonData);
      File file = File(filePath);

      await file.writeAsString(jsonString);
    } catch (e) {}
  }

}
