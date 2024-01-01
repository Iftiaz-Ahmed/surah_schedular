import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:surah_schedular/src/models/formInputs.dart';
import 'package:surah_schedular/src/models/prayerMethod.dart';
import 'package:surah_schedular/src/models/todaysAzaan.dart';

import '../models/surah.dart';

class ApiServices {
  Future getAzaanTime(FormInputs inputs) async {
    TodayAzaan todayAzaan = TodayAzaan();
    try {
      var response = await http.get(Uri.parse("http://api.aladhan.com/v1/timingsByAddress?address=${inputs.address}&method=${inputs.method}&school=${inputs.school}"));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        todayAzaan.date = jsonResponse['data']['date']['readable'];
        todayAzaan.prayerTimes = {
          "Fajr": jsonResponse['data']['timings']['Fajr'],
          "Dhuhr": jsonResponse['data']['timings']['Dhuhr'],
          "Asr": jsonResponse['data']['timings']['Asr'],
          "Maghrib": jsonResponse['data']['timings']['Maghrib'],
          "Isha": jsonResponse['data']['timings']['Isha'],
        };
        todayAzaan.gregorianDate =
            jsonResponse['data']['date']['gregorian']['date'];

        todayAzaan.getAzaanTime();

        return todayAzaan;
      } else {
        print("Prayer Timings not found");
      }
    } on HttpException {
      print("http exception");
    }
    return todayAzaan;
  }

  Future getPrayerMethodList() async {
    List<PrayerMethod> list = [];
    try {
      final response =
          await http.get(Uri.parse('http://api.aladhan.com/v1/methods'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        Map<String, dynamic> data = jsonResponse['data'];

        data.forEach((key, value) {
          PrayerMethod prayerMethod =
              PrayerMethod(id: value["id"], name: value["name"], code: key);
          list.add(prayerMethod);
        });

        return list;
      }
    } on HttpException {
      print("http exception");
    }
    return list;
  }

  Future getSurahList() async {
    List<Surah> list = [];
    try {
      final response =
          await http.get(Uri.parse('http://api.alquran.cloud/v1/surah'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        List data = jsonResponse['data'];

        for (var item in data) {
          String source =
              "https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/${item['number'].toString()}.mp3";
          Surah surah = Surah(
              number: item['number'],
              name: item['englishName'],
              nameMeaning: item['englishNameTranslation'],
              source: source);
          list.add(surah);
        }

        return list;
      }
    } on HttpException {
      print("http exception");
    }
    return list;
  }
}
