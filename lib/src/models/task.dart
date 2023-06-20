import 'dart:async';

class Task {
  String name;
  String date;
  String time;
  Timer? taskTimer;

  Task({required this.name, required this.date, required this.time, required this.taskTimer});

  String getName() {
    return name;
  }
}
