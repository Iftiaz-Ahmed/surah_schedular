import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:surah_schedular/src/models/formInputs.dart';
import 'package:surah_schedular/src/models/prayerMethod.dart';
import 'package:surah_schedular/src/models/schedular.dart';
import 'package:surah_schedular/src/models/todaysAzaan.dart';
import 'package:surah_schedular/src/services/api_services.dart';

import '../models/surah.dart';

class AzaanBloc extends ChangeNotifier {
  final ApiServices _apiServices = ApiServices();

  FormInputs _formInputs = FormInputs();
  get formInputs => _formInputs;
  set formInputs(var value) {
    _formInputs = value;
    print(_formInputs);
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

  Future getTodayAzaan(String? city, String? country, int? method, int? school) async {
    await _apiServices.getAzaanTime(city, country, method, school).then((value) {
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

  Future<void> setSchedularTimer() async {
    prayerSchedular.cancelAllTimers();
    TodayAzaan todayAzaan = _todayAzaan;
    todayAzaan.prayerTimes?.forEach((key, value) {
      prayerSchedular.addNewSchedule(key, todayAzaan.gregorianDate, value, 0, "", 0);
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
}
