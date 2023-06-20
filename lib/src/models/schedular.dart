import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:surah_schedular/src/models/task.dart';

class Schedular {
  final player = AudioPlayer();
  int scheduleCount = 0;
  List<Task> tasks = [];

  Schedular();

  List<int> convertDateTime(String dateTime, String separator) {
    List<String> values = dateTime.split(separator);
    return values.map<int>((e) => int.parse(e)).toList();
  }

  void startTimer(Duration duration, Task task) {
    Timer newTimer = Timer(duration, () {
      print('Task executed at ${task.time} on ${task.date}');

      player.play(DeviceFileSource("assets/audio/makkah_adhan.mp3"));
    });

    task.taskTimer = newTimer;
    tasks.add(task);
  }

  Future<void> addNewSchedule(String name, String date, String time) async {
    List convertedDate = convertDateTime(date, "-");
    List convertedTime = convertDateTime(time, ":");

    var currentTime = DateTime.now();
    var desiredTime = DateTime(convertedDate[2], convertedDate[1], convertedDate[0], convertedTime[0], convertedTime[1], 0);

    if (currentTime.isAfter(desiredTime)) {
      desiredTime = desiredTime.add(const Duration(days: 1));
    }

    var duration = desiredTime.difference(currentTime);

    Task task = Task(name: name, date: date, time: time, taskTimer: null);
    startTimer(duration, task);
    scheduleCount++;
  }

  Future<void> stopPlayer() async {
    await player.stop();
    print("player stopped");
  }

  void cancelAllTimers() {
    print('Timers cleared');
    stopPlayer();
    for (var task in tasks) {
      task.taskTimer?.cancel();
    }

    tasks.clear();
  }

  void getScheduleCount() {
    print("Total Schedule: ${scheduleCount}");
  }

  void printActiveTasks() {
    tasks.forEach((element) {
      print("${element.name} scheduled at ${element.time}");
    });
  }
}
