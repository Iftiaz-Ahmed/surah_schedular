import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:localstorage/localstorage.dart';
import 'package:surah_schedular/src/models/task.dart';
import 'package:surah_schedular/src/provider/azaan_bloc.dart';

class Schedular {
  final player = AudioPlayer();
  final AzaanBloc azaanBloc;
  int scheduleCount = 0;
  List<Task> tasks = [];

  Schedular(this.azaanBloc) {
    retrieveTasks();
  }

  List<int> convertDateTime(String dateTime, String separator) {
    List<String> values = dateTime.split(separator);
    return values.map<int>((e) => int.parse(e)).toList();
  }

  Future textToSpeech(String text) async {
    FlutterTts flutterTts = FlutterTts();

    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.2);
    await flutterTts.setVolume(1);
    await flutterTts.setVoice({"name": "Karen", "locale": "en-US"});

    // if (azaanBloc.castConnected) {
    //   return;
    // }

    await flutterTts.speak(text).then((value) {
      print('speak');
      print(value);
    });
  }

  bool isPlaying() {
    return player.state == PlayerState.playing ? true : false;
  }

  void startTimer(Duration duration, Task task, double volume) {
    Timer? newTimer = duration.isNegative
        ? null
        : Timer(duration, () async {
      AudioPlayer temPlayer = AudioPlayer();
      FlutterVolumeController.setVolume(volume / 100);
      player.setVolume(volume / 100);
      print('Task scheduled at ${task.time} on ${task.date}');
      print("Executed at ${DateTime.now()}");
      String title = task.isSurah
          ? "Now playing  Surah  ${task.name}"
          : "Now playing   ${task.name} Adhaan";

      if (player.state == PlayerState.playing) {
        player.pause().then((value) {
          temPlayer.setVolume(volume / 100);
          textToSpeech(title).then((value) {
            Future.delayed(const Duration(seconds: 3), () {
              //Not controlling cast device yet
              if (azaanBloc.castConnected) {
                // azaanBloc.sendMessagePlayAudio(value);
                azaanBloc.sendMessagePlayAudio(task);
              } else {
                if (task.sourceType == 0) {
                  temPlayer.play(DeviceFileSource(task.source));
                } else {
                  temPlayer.play(UrlSource(task.source));
                }
                temPlayer.onPlayerComplete.listen((event) async {
                  await player.resume();
                });
              }
            });
          });
        });
      } else {
        await textToSpeech(title).then((value) {
          Future.delayed(const Duration(seconds: 3), () {
            if (azaanBloc.castConnected) {
              azaanBloc.sendMessagePlayAudio(task);
            } else {
              if (task.sourceType == 0) {
                player.play(DeviceFileSource(task.source));
              } else {
                player.play(UrlSource(task.source));
              }
            }
          });
        });
      }
    });

    task.taskTimer = newTimer;
    tasks.add(task);
  }

  PlayerState playerState() {
    return player.state;
  }

  Future<void> addNewSchedule(
      String name,
      String date,
      String time,
      int scheduleType,
      String source,
      int frequency,
      double volume,
      bool isSurah) async {
    List convertedDate = convertDateTime(date, "-");
    List convertedTime = convertDateTime(time, ":");

    var currentTime = DateTime.now();
    DateTime desiredTime = DateTime(convertedDate[2], convertedDate[1],
        convertedDate[0], convertedTime[0], convertedTime[1], 0);

    if (frequency == 0) {
      // functions for once freq.
    } else if (frequency == 1) {
      desiredTime = DateTime(currentTime.year, currentTime.month,
          currentTime.day, convertedTime[0], convertedTime[1], 0);
    } else if (frequency == 2) {
      int todayWeekday = currentTime.weekday;
      int weekday = desiredTime.weekday;
      if (todayWeekday == weekday) {
        desiredTime = DateTime(currentTime.year, currentTime.month,
            currentTime.day, convertedTime[0], convertedTime[1], 0);
        if (currentTime.isAfter(desiredTime)) {
          desiredTime = desiredTime.add(Duration(days: 7));
        }
      } else {
        return;
      }
    }

    var duration = desiredTime.difference(currentTime);

    Task task = Task(
        name: name,
        date: date,
        time: time,
        taskTimer: null,
        frequency: frequency,
        sourceType: scheduleType,
        isSurah: isSurah,
        source: source,
        volume: volume);
    startTimer(duration, task, volume);

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
    List<String> stringTasks = [];
    for (var item in tasks) {
      if (item.isSurah) {
        stringTasks.add(item.toString());
      }
    }
    azaanBloc.surahTaskList = stringTasks;
    azaanBloc.saveDataLocally("schedular");
  }

  Future<void> retrieveTasks() async {
    try {
      tasks.clear();
      final LocalStorage storage = LocalStorage('surah_schedular.json');
      await storage.clear();
      List items = [];
      await storage.ready.then((value) {
        items = storage.getItem('tasks') ?? [];
      });

      for (var item in items) {
        final jsonMap = jsonDecode(item) as Map<String, dynamic>;
        if (jsonMap['isSurah']) {
          addNewSchedule(
              jsonMap['name'],
              jsonMap['date'],
              jsonMap['time'],
              jsonMap['sourceType'],
              jsonMap['source'],
              jsonMap['frequency'],
              jsonMap['volume'],
              jsonMap['isSurah']);
        }
      }
    } catch (e) {}
  }

  deleteTask(int index) {
    tasks[index].taskTimer?.cancel();
    stopPlayer();
    tasks.removeAt(index);
    saveTasks();
  }
}
