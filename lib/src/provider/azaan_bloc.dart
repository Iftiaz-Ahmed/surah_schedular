import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:surah_schedular/src/models/formInputs.dart';
import 'package:surah_schedular/src/models/prayerMethod.dart';
import 'package:surah_schedular/src/models/schedular.dart';
import 'package:surah_schedular/src/models/todaysAzaan.dart';
import 'package:surah_schedular/src/services/api_services.dart';

import '../models/surah.dart';

class AzaanBloc extends ChangeNotifier {
  final ApiServices _apiServices = ApiServices();

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
    print(_formInputs);
    notifyListeners();
  }

  Future<List> getLatLng(FormInputs inputs) async {
    List list = [];
    list = await _apiServices.getLatLng(inputs) ?? [];

    return list;
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

  Schedular _prayerSchedular = Schedular();
  get prayerSchedular => _prayerSchedular;
  set prayerSchedular(var value) {
    _prayerSchedular = value;
    notifyListeners();
  }

  Schedular _surahSchedular = Schedular();
  get surahSchedular => _surahSchedular;
  set surahSchedular(var value) {
    _surahSchedular = value;
    notifyListeners();
  }

  Future<void> setAzaanTimes(source) async {
    Map azaan = {"Fajr": 0, "Dhuhr": 1, "Asr": 2, "Maghrib": 3, "Isha": 4};
    prayerSchedular.cancelAllTimers();
    TodayAzaan todayAzaan = _todayAzaan;

    todayAzaan.prayerTimes?.forEach((key, value) {
      prayerSchedular.addNewSchedule(key, todayAzaan.gregorianDate, value, 0,
          source, 0, azaanVolumes[azaan[key]]);
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

    print("before ${format.format(azaanTime)}");

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

  List _adhanList = [];
  get adhanList => _adhanList;
  set adhanList(var value) {
    _adhanList = value;
    notifyListeners();
  }

  Map _selectedAdhan = {
    "name": "Masjid Al-Haram in Mecca.mp3",
    "path": "assets/audio/Masjid Al-Haram in Mecca.mp3",
    "type": 0
  };
  get selectedAdhan => _selectedAdhan;
  set selectedAdhan(var value) {
    _selectedAdhan = value;
    notifyListeners();
  }

  Future<void> getAdhanFileNames() async {
    List<String> audioFileNames = [];
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      for (String key in manifestMap.keys) {
        if (key.contains('assets/audio') && key.endsWith('.mp3')) {
          audioFileNames.add(key.split('/').last);
        }
      }
    } catch (e) {
      print("Error reading audio files: $e");
    }
    adhanList = audioFileNames;
  }
}
