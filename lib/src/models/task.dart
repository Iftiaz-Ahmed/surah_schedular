import 'dart:async';
import 'dart:convert';

class Task {
  String name;
  String date;
  String time;
  Timer? taskTimer;
  int frequency;
  int sourceType; // 0 device, 1 online
  var source;
  double volume;

  Task(
      {required this.name,
      required this.date,
      required this.time,
      required this.taskTimer,
      required this.frequency,
      required this.sourceType,
      required this.source,
      required this.volume});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date,
      'time': time,
      'frequency': frequency,
      'sourceType': sourceType,
      'source': source,
      'volume': volume
    };
  }

  @override
  String toString() {
    final json = jsonEncode(toJson());
    return json;
  }
}
