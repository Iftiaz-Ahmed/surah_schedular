import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_tts/flutter_tts.dart';
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

  Future<void> addNewSchedule(String name, String date, String time, int scheduleType, String source) async {
    List convertedDate = convertDateTime(date, "-");
    List convertedTime = convertDateTime(time, ":");

    var currentTime = DateTime.now();
    var desiredTime = DateTime(convertedDate[2], convertedDate[1], convertedDate[0], convertedTime[0], convertedTime[1], 0);

    if (currentTime.isAfter(desiredTime)) {
      desiredTime = desiredTime.add(const Duration(days: 1));
    }

    var duration = desiredTime.difference(currentTime);

    if (scheduleType == 0) {
      Task task = Task(name: name, date: date, time: time, taskTimer: null, sourceType: scheduleType, source: "assets/audio/makkah_adhan.mp3");
      startTimer(duration, task);
    } else {
      Task task = Task(name: name, date: date, time: time, taskTimer: null, sourceType: scheduleType, source: source);
      startTimer(duration, task);
    }

    scheduleCount++;
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
}
