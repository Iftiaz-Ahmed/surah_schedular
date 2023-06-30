import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_tts/flutter_tts.dart';
import 'package:surah_schedular/src/models/task.dart';

class Schedular {
  final player = AudioPlayer();
  int scheduleCount = 0;
  List<Task> tasks = [];

  Schedular() {
    retrieveTasks();
  }

  List<int> convertDateTime(String dateTime, String separator) {
    List<String> values = dateTime.split(separator);
    return values.map<int>((e) => int.parse(e)).toList();
  }

  // Future<void> textToSpeech(String text) async {
  //   FlutterTts flutterTts = FlutterTts();
  //   await flutterTts.setLanguage("en-US");
  //   await flutterTts.setSpeechRate(0.5);
  //   await flutterTts.setVoice({"name": "Karen", "locale": "en-AU"});
  //   await flutterTts.speak(text);
  // }

  void startTimer(Duration duration, Task task) {
    Timer newTimer = Timer(duration, () async {
      print('Task executed at ${task.time} on ${task.date}');
      // await textToSpeech(task.name).then((value) {
      //   player.play(DeviceFileSource("assets/audio/makkah_adhan.mp3"));
      // });
      if (task.sourceType == 0) {
        player.play(DeviceFileSource("assets/audio/makkah_adhan.mp3"));
      } else {
        player.play(UrlSource(task.source));
      }
    });

    task.taskTimer = newTimer;
    tasks.add(task);
  }

  PlayerState playerState() {
    return player.state;
  }

  Future<void> addNewSchedule(String name, String date, String time, int scheduleType, String source, int frequency) async {
    List convertedDate = convertDateTime(date, "-");
    List convertedTime = convertDateTime(time, ":");

    var currentTime = DateTime.now();
    var desiredTime = DateTime(convertedDate[2], convertedDate[1], convertedDate[0], convertedTime[0], convertedTime[1], 0);

    if (frequency == 1) {
      desiredTime = DateTime(currentTime.year, currentTime.month, currentTime.day, convertedTime[0], convertedTime[1], 0);
    } else if (frequency == 2) {
      int todayWeekday = currentTime.weekday;
      int weekday = desiredTime.weekday;
      if (todayWeekday == weekday) {
        desiredTime = DateTime(currentTime.year, currentTime.month, currentTime.day, convertedTime[0], convertedTime[1], 0);
      }
    }

    if (currentTime.isAfter(desiredTime)) {
      desiredTime = desiredTime.add(const Duration(days: 1));
    }

    var duration = desiredTime.difference(currentTime);

    if (scheduleType == 0) {
      Task task = Task(
          name: name,
          date: date,
          time: time,
          taskTimer: null,
          frequency: frequency,
          sourceType: scheduleType,
          source: "assets/audio/makkah_adhan.mp3");
      startTimer(duration, task);
      print("${task.name} scheduled at ${task.date}, ${task.time}");
    } else {
      Task task = Task(name: name, date: date, time: time, taskTimer: null, frequency: frequency, sourceType: scheduleType, source: source);
      startTimer(duration, task);
      print("${task.name} scheduled at ${task.date}, ${task.time}");
    }
    scheduleCount++;
    saveTasks();
  }

  Future<void> stopPlayer() async {
    await player.stop();
    print("player stopped");
  }

  Future<void> pausePlayer() async {
    await player.pause();
    print("player paused");
  }

  Future<void> resumePlayer() async {
    await player.resume();
    print("player resumed");
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

  Future<void> saveTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringTasks = [];
    for (var item in tasks) {
      if (item.sourceType == 1) {
        stringTasks.add(item.toString());
      }
    }
    await prefs.setStringList('tasks', stringTasks);
  }

  Future<void> retrieveTasks() async {
    tasks.clear();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? items = prefs.getStringList('tasks');
    if (items != null) {
      items.forEach((item) {
        print(items);
        final jsonMap = jsonDecode(item) as Map<String, dynamic>;
        if (jsonMap['sourceType'] == 1) {
          addNewSchedule(jsonMap['name'], jsonMap['date'], jsonMap['time'], jsonMap['sourceType'], jsonMap['source'], jsonMap['frequency']);
        }
      });
    }
  }

  deleteTask(int index) {
    tasks[index].taskTimer?.cancel();
    stopPlayer();
    tasks.removeAt(index);
    saveTasks();
  }
}
