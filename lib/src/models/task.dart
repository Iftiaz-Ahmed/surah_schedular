import 'dart:async';

class Task {
  String name;
  String date;
  String time;
  Timer? taskTimer;
  int sourceType; // 0 device, 1 online
  var source;

  Task({required this.name, required this.date, required this.time, required this.taskTimer, required this.sourceType, required this.source});

  String getName() {
    return name;
  }
}
