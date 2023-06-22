import 'package:flutter/cupertino.dart';
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
      prayerSchedular.addNewSchedule(key, todayAzaan.gregorianDate, value, 0, "");
    });
    prayerSchedular.printActiveTasks();
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
}
