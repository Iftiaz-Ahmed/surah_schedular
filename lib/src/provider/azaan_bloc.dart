import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:surah_schedular/src/models/formInputs.dart';
import 'package:surah_schedular/src/models/prayerMethod.dart';
import 'package:surah_schedular/src/models/schedular.dart';
import 'package:surah_schedular/src/models/todaysAzaan.dart';
import 'package:surah_schedular/src/services/api_services.dart';

import '../models/adhan.dart';
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

  Schedular _schedular = Schedular();
  get schedular => _schedular;
  set schedular(var value) {
    _schedular = value;
    notifyListeners();
  }

  // Schedular _surahSchedular = Schedular();
  // get surahSchedular => _surahSchedular;
  // set surahSchedular(var value) {
  //   _surahSchedular = value;
  //   notifyListeners();
  // }

  Future<void> setAzaanTimes(source) async {
    Map azaan = {"Fajr": 0, "Dhuhr": 1, "Asr": 2, "Maghrib": 3, "Isha": 4};
    schedular.cancelAllTimers();
    TodayAzaan todayAzaan = _todayAzaan;

    todayAzaan.prayerTimes?.forEach((key, value) {
      schedular.addNewSchedule(key, todayAzaan.gregorianDate, value,
          _selectedAdhan.type, source, 0, azaanVolumes[azaan[key]], false);
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
    adhanList = audioFileNames;
  }
}
