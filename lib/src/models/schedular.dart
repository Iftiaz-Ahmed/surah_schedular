import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cast/cast.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:surah_schedular/src/models/task.dart';
import 'package:surah_schedular/src/provider/azaan_bloc.dart';
import '../models/formInputs.dart';
import 'package:surah_schedular/src/models/localData.dart';

class Schedular {
  final player = AudioPlayer();
  final AzaanBloc azaanBloc;
  int scheduleCount = 0;
  List<Task> tasks = [];
  String installationDirectory = "";

  Schedular(this.azaanBloc) {
    installationDirectory = azaanBloc.getInstallationDirectory();
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

    if (azaanBloc.castConnected) {
      return;
    }

    await flutterTts.speak(text);
  }

  bool isPlaying() {
    return player.state == PlayerState.playing ? true : false;
  }

  void startTimer(Duration duration, Task task, double volume) {
    print("Name: ${task.name},  Duration ${duration.toString()}");

    try {
      Timer? newTimer = duration.isNegative
          ? null
          : Timer(duration, () async {
        AudioPlayer temPlayer = AudioPlayer();
        FlutterVolumeController.setVolume(volume / 100);
        player.setVolume(volume / 100);
        print('Task scheduled at ${task.time} on ${task.date}');
        print("Executed at ${DateTime.now()}");
        String title = task.isSurah
            ? task.sourceType == 1 ? "Now playing  Surah  ${task.name}" : "Now playing  ${task.name}"
            : "Now playing   ${task.name} Adhaan";

        if (player.state == PlayerState.playing) {
          player.pause().then((value) {
            temPlayer.setVolume(volume / 100);
            textToSpeech(title).then((value) {
              Future.delayed(const Duration(seconds: 3), () {
                if (azaanBloc.castConnected) {
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

        //saving log records
        azaanBloc.logs.saveLogs(installationDirectory, "${task.name} played at ${task.time}");

        if (!task.isSurah && azaanBloc.playDua) {
          AudioPlayer duaPlayer = AudioPlayer();
          player.onPlayerComplete.listen((event) {
            duaPlayer.play(UrlSource("https://drive.google.com/uc?id=1w-z33xIW4_5Xp6TFsJLC2_fE0It3LKrY"));
          });
        }
      });

      task.taskTimer = newTimer;
      tasks.add(task);
    } catch(e) {
      azaanBloc.logs.saveLogs(installationDirectory, "Error occurred while playing ${task.name} at ${task.time}");
    }
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
      bool isSurah,
      String timeString) async {
    List convertedDate = convertDateTime(date, "-");
    List convertedTime = convertDateTime(time, ":");

    var currentTime = DateTime.now();
    DateTime desiredTime = DateTime(convertedDate[2], convertedDate[1],
        convertedDate[0], convertedTime[0], convertedTime[1], 0);

    if (timeString!="") { //recalculating time
        int whenIndex = 0;
        int unitIndex = 0;
        int t = 0;
        if (timeString.contains("before")) whenIndex = 0; else whenIndex = 1;
        if (timeString.contains("hour")) unitIndex = 0; else unitIndex = 1;

        List<String> parts = timeString.split(" ");
        try {
          t = int.parse(parts[0]);
        } catch (e) {}
        String prayer = parts[3];
        String calTime = "";

          calTime = azaanBloc.calculateScheduleTime(prayer, whenIndex, unitIndex, t);
          convertedTime = convertDateTime(calTime.toString(), ":");

    }

    if (frequency == 0) {
      // functions for once freq.
    } else if (frequency == 1) {
      desiredTime = DateTime(currentTime.year, currentTime.month,
          currentTime.day, convertedTime[0], convertedTime[1], 0);
      date = "${currentTime.day}-${currentTime.month}-${currentTime.year}";
    } else if (frequency == 2) {
      int todayWeekday = currentTime.weekday;
      int weekday = desiredTime.weekday;
      if (todayWeekday == weekday) {
        desiredTime = DateTime(currentTime.year, currentTime.month,
            currentTime.day, convertedTime[0], convertedTime[1], 0);
        if (currentTime.isAfter(desiredTime)) {
          desiredTime = desiredTime.add(Duration(days: 7));
          date = "${currentTime.day}-${currentTime.month}-${currentTime.year}";
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
        volume: volume,
        timeString: timeString);
    startTimer(duration, task, volume);

    scheduleCount++;
    if (isSurah) {
      saveTasks();
    }
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
    print("Total Schedule: $scheduleCount");
  }

  void printActiveTasks() {
    for (var element in tasks) {
      print("${element.name} scheduled at ${element.time} ${element.date} ${element.frequency}");
    }
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

  void removeSurahTasks(List<Task> tasks) {
    tasks.removeWhere((task) => task.isSurah);
  }

  Future<void> retrieveTasks() async {
    try {
      removeSurahTasks(tasks);
      LocalData localData = LocalData();
      Map<String, dynamic> savedFileData = await localData.readJsonFile(installationDirectory);
      List items = savedFileData['tasks'] ?? [];

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
              jsonMap['isSurah'],
              jsonMap['timeString']);
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
