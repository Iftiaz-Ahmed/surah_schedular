import 'dart:io';
import 'package:cast/device.dart';
import 'package:cast/session.dart';
import 'package:cast/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:surah_schedular/src/models/formInputs.dart';
import 'package:surah_schedular/src/models/localData.dart';
import 'package:surah_schedular/src/models/prayerMethod.dart';
import 'package:surah_schedular/src/models/schedular.dart';
import 'package:surah_schedular/src/models/task.dart';
import 'package:surah_schedular/src/models/todaysAzaan.dart';
import 'package:surah_schedular/src/services/api_services.dart';
import 'package:path/path.dart';

import '../models/adhan.dart';
import '../models/surah.dart';
import '../models/LogManager.dart';


class AzaanBloc extends ChangeNotifier {
  final ApiServices _apiServices = ApiServices();

  late Schedular _schedular;

  AzaanBloc() {
    _schedular = Schedular(this);
  }

  String getInstallationDirectory() {
    try {
      String executablePath = Platform.resolvedExecutable;
      String installationDirectory = dirname(executablePath);

      return installationDirectory;
    } catch (e) {
      print('Error getting installation directory: $e');
      return "";
    }
  }

  List _azaanVolumes = [70.0, 70.0, 70.0, 70.0, 70.0];
  get azaanVolumes => _azaanVolumes;
  set azaanVolumes(var value) {
    _azaanVolumes = value;
    notifyListeners();
  }

  FormInputs _formInputs = FormInputs();
  get formInputs => _formInputs;
  set formInputs(var value) {
    _formInputs = value;
    notifyListeners();
  }

  TodayAzaan _todayAzaan = TodayAzaan();
  get todayAzaan => _todayAzaan;
  set todayAzaan(var value) {
    _todayAzaan = value;
    notifyListeners();
  }

  bool _azaanTimeStatus = false;
  bool get azaanTimeStatus => _azaanTimeStatus;
  set azaanTimeStatus(bool value) {
    _azaanTimeStatus = value;
    notifyListeners();
  }

  AdhanItem _selectedAdhan = AdhanItem(
      name: "Azaan 12",
      path: "https://www.islamcan.com/audio/adhan/azan12.mp3",
      type: 1);
  get selectedAdhan => _selectedAdhan;
  set selectedAdhan(var value) {
    _selectedAdhan = value;
    notifyListeners();
  }

  Future getTodayAzaan(FormInputs inputs) async {
    await _apiServices.getAzaanTime(inputs).then((value) {
      if (value != []) {
        azaanTimeStatus = true;
      } else {
        azaanTimeStatus = false;
      }

      todayAzaan = value;
    });
    return todayAzaan;
  }

  List<PrayerMethod> _prayerMethodList = [];
  get prayerMethodList => _prayerMethodList;
  set prayerMethodList(var value) {
    _prayerMethodList = value;
    notifyListeners();
  }

  Future getPrayerMethod() async {
    await _apiServices.getPrayerMethodList().then((value) {
      _prayerMethodList = value;
    });
    return _prayerMethodList;
  }

  // initialized in constructor
  get schedular => _schedular;
  set schedular(var value) {
    _schedular = value;
    notifyListeners();
  }


  Future<void> setAzaanTimes(source) async {
    Map azaan = {"Fajr": 0, "Dhuhr": 1, "Asr": 2, "Maghrib": 3, "Isha": 4};
    schedular.cancelAllTimers();
    TodayAzaan todayAzaan = _todayAzaan;

    todayAzaan.prayerTimes?.forEach((key, value) {
      schedular.addNewSchedule(key, todayAzaan.gregorianDate, value,
          _selectedAdhan.type, source, 0, azaanVolumes[azaan[key]], false, "");
    });
  }

  List<Surah> _surahList = [];
  get surahList => _surahList;
  set surahList(var value) {
    _surahList = value;
    notifyListeners();
  }

  Future getSurahList() async {
    if (_surahList.isEmpty) {
      await _apiServices.getSurahList().then((value) {
        _surahList = value;
      });
    }
    return _surahList;
  }

  String calculateScheduleTime(String prayer, int when, int unit, int time) {
    String? prayerTime = _todayAzaan.getPrayerTime(prayer);
    DateFormat format = DateFormat('HH:mm');
    DateTime azaanTime = DateFormat('HH:mm').parse(prayerTime!);
    DateTime calculatedTime = DateTime.now();


    if (when == 0) {
      // set time before the prayer
      if (unit == 0) {
        // means hour
        calculatedTime = azaanTime.add(Duration(hours: -time));
      } else {
        calculatedTime = azaanTime.add(Duration(minutes: -time));
      }
    } else {
      // set time after prayer
      if (unit == 0) {
        // means hour
        calculatedTime = azaanTime.add(Duration(hours: time));
      } else {
        calculatedTime = azaanTime.add(Duration(minutes: time));
      }
    }
    return format.format(calculatedTime);
  }

  List<AdhanItem> _adhanList = [];
  get adhanList => _adhanList;
  set adhanList(var value) {
    _adhanList = value;
    notifyListeners();
  }

  Future<void> getAdhanFileNames() async {
    List<AdhanItem> audioFileNames = [];
    for (int i = 1; i <= 21; i++) {
      AdhanItem item = AdhanItem(
          name: "Azaan $i",
          path: "https://www.islamcan.com/audio/adhan/azan$i.mp3",
          type: 1);
      audioFileNames.add(item);
    }
    audioFileNames.add(AdhanItem(name: "Ahmad Al Nafees", path: "https://iftiazahmed.com/azaans/Ahmad-Al-Nafees.mp3", type: 1));
    audioFileNames.add(AdhanItem(name: "Masjid Al-Haram in Mecca", path: "https://iftiazahmed.com/azaans/Masjid-Al-Haram-in-Mecca.mp3", type: 1));
    audioFileNames.add(AdhanItem(name: "Mishary Rashid Alafasy", path: "https://iftiazahmed.com/azaans/Mishary-Rashid-Alafasy.mp3", type: 1));
    adhanList = audioFileNames;
  }

  bool _castConnected = false;
  bool get castConnected => _castConnected;
  set castConnected(var value) {
    _castConnected = value;
    notifyListeners();
  }

  CastDevice _castDevice =
  CastDevice(serviceName: "", name: "", host: "", port: 0);
  CastDevice get castDevice => _castDevice;
  set castDevice(var value) {
    _castDevice = value;
    notifyListeners();
  }

  dynamic requestId;
  dynamic mediaSessionId = 1;
  late dynamic _castSession;

  Future sendMessagePlayAudio(Task task) async {
    print(task.name);
    if (castDevice.name.isEmpty) {
      return;
    }

    if (CastSessionManager().sessions.isNotEmpty) {
      // ending session, if already connected
      CastSessionManager()
          .endSession(CastSessionManager().sessions.first.sessionId);
    }

    final session = await CastSessionManager()
        .startSession(castDevice); // making new connection
    _castSession = session;
    session.stateStream.listen((state) {
      if (state == CastSessionState.connected) {}
    });

    var index = 0;

    session.messageStream.listen((message) {
      index += 1;


      if (index == 2 || index == 1) {
        Future.delayed(Duration(seconds: 0)).then((x) {
          requestId = message['requestId'];
          _sendMessagePlayVideo(session, task);
        });
      }

      try{
        if (message['status'] != null && message['status'] == []) {
          if (message['status'][0] != [] &&
              message['status'][0]['playerState'] == 'PLAYING') {
            mediaSessionId = message['status'][0]['mediaSessionId'];
          }}

        if (message['status'][0]['idleReason'] == "FINISHED") {
          if (!task.isSurah && playDua) {
            Task dua = Task(
                name: "Azaan Dua",
                date: task.date,
                time: task.time,
                taskTimer: task.taskTimer,
                frequency: task.frequency,
                sourceType: task.sourceType,
                isSurah: true,
                source: "https://iftiazahmed.com/azaans/Dua-After-The-Azan.mp3",
                volume: task.volume,
                timeString: task.timeString);
            sendMessagePlayAudio(dua);
          }
        }
      } catch(e) {}
    });

    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'LAUNCH',
      'appId': 'CC1AD845', // set the appId of your app here
    });

  }

  void _sendMessagePlayVideo(CastSession session, Task task) {

    var message = {
      // Here you can plug an URL to any mp4, webm, mp3 or jpg file with the proper contentType.
      'contentId': task.source,
      'contentType': 'audio/mp3',
      'streamType': 'BUFFERED', // or LIVE

      // Title and cover displayed while buffering
      'metadata': {
        'type': 0,
        'metadataType': 0,
        'title': task.name,
      }
    };

    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'LOAD',
      'autoPlay': true,
      'currentTime': 0,
      'media': message,
    });
  }

  Future<void> pauseCastAudio() async {
    if (requestId != null) {
      _castSession.sendMessage(CastSession.kNamespaceMedia, {
        'type': 'PAUSE',
        'requestId': requestId,
        'mediaSessionId': mediaSessionId,
      });
    }
  }

  Future<void> playCastAudio() async {
    if (requestId != null) {
      _castSession.sendMessage(CastSession.kNamespaceMedia, {
        'type': 'PLAY',
        'requestId': requestId,
        'mediaSessionId': mediaSessionId,
      });
    }
  }

  List<String> _surahTaskList = [];
  List<String> get surahTaskList => _surahTaskList;
  set surahTaskList(List<String> value) {
    _surahTaskList = value;
    notifyListeners();
  }

  Future<void> saveDataLocally(String calledFrom) async {
    var device = {
      'serviceName': castDevice.serviceName,
      'name': castDevice.name,
      'host': castDevice.host,
      'port': castDevice.port,
      'extras': castDevice.extras
    };

    LocalData localData = LocalData();
    String installationDirectory = getInstallationDirectory();
    await localData.saveInfo(installationDirectory, formInputs, selectedAdhan, surahTaskList, azaanVolumes, device, calledFrom);
  }

  bool _playDua = true;
  bool get playDua => _playDua;
  set playDua(bool value) {
    _playDua = value;
    notifyListeners();
  }

  LogManager _logs = LogManager();
  LogManager get logs => _logs;
  set logs(var value) {
    _logs = value;
    notifyListeners;
  }
}
