import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart'; // REQUIRED for reading assets (rootBundle)
import 'package:path_provider/path_provider.dart';

class GlobalVariables {
  static const String _fileName = 'global.json';

  // Make sure this matches the path in your pubspec.yaml
  static const String _assetPath = 'assets/global.json';

  // Load persistent variables
  static Future<Map<String, int>> load() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');

      // Look for the file on the user's device
      if (await file.exists()) {
        String content = await file.readAsString();
        Map<String, dynamic> jsonMap = json.decode(content);
        return jsonMap.map((key, value) => MapEntry(key, value as int));
      }
      // File doesn't exist (first run). Load from the assets folder.
      else {
        String assetContent = await rootBundle.loadString(_assetPath);
        Map<String, dynamic> jsonMap = json.decode(assetContent);
        Map<String, int> defaultVariables = jsonMap.map((key, value) => MapEntry(key, value as int));

        // STEP 3: Save these default variables to the user's device so it's there next time
        await save(defaultVariables);

        return defaultVariables;
      }
    } catch (e) {
      print("Error loading global variables: $e");
    }
    return {};
  }

  // Save persistent variables
  static Future<void> save(Map<String, int> variables) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      String content = json.encode(variables);
      await file.writeAsString(content);
    } catch (e) {
      print("Error saving global variables: $e");
    }
  }
}