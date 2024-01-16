import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

class LogManager {
    Map<String, dynamic> logs = {};

    Future<Map<String, dynamic>> readLogFile(String path) async {
        // Specify the path to your JSON file
        String filePath = '$path\\logs.json';
        print('reading logs');
        try {
            File file = File(filePath);
            if (await file.exists()) {
                // Read the JSON file
                String contents = await file.readAsString();

                // Parse the JSON content
                Map<String, dynamic> jsonData = jsonDecode(contents);
                logs = jsonData;
                return jsonData;
            }
        } catch (e) {
            print('Error reading JSON file: $e');
        }
        return {};
    }

    Future<void> saveLogs(String path, String msg) async {
        DateTime currentDate = DateTime.now();
        String formattedDate = DateFormat('MM/dd/yyyy').format(currentDate);
        print("savings logs");
        try {
            Map<String, dynamic> jsonData = await readLogFile(path);

            print('time to be added');
            print(jsonData[formattedDate]);
            List items = jsonData[formattedDate] ?? [];
            items.add(msg);
            print("Items: $items");
            jsonData[formattedDate] = items;

            // Specify the file path
            String filePath = '$path\\logs.json';
            logs = jsonData;
            // Convert JSON data to a string
            String jsonString = jsonEncode(jsonData);
            File file = File(filePath);

            print("JsonString $jsonString");
            await file.writeAsString(jsonString);
            print("Written at $filePath");
        } catch (e) {}
    }



}