import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:surah_schedular/src/models/prayerMethod.dart';
import 'package:surah_schedular/src/models/todaysAzaan.dart';

class ApiServices {
  Future getAzaanTime(String? city, String? country, int? method, int? school) async {
    TodayAzaan todayAzaan = TodayAzaan();
    try {
      final response =
          await http.get(Uri.parse('http://api.aladhan.com/v1/timingsByCity?city=${city}&country=${country}&method=${method}&school=${school}'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        todayAzaan.date = jsonResponse['data']['date']['readable'];
        todayAzaan.prayerTimes = {
          "Fajr": jsonResponse['data']['timings']['Fajr'].toString(),
          "Dhuhr": jsonResponse['data']['timings']['Dhuhr'],
          "Asr": jsonResponse['data']['timings']['Asr'],
          "Maghrib": jsonResponse['data']['timings']['Maghrib'],
          "Isha": jsonResponse['data']['timings']['Isha'],
        };
        todayAzaan.gregorianDate = jsonResponse['data']['date']['gregorian']['date'];

        todayAzaan.getAzaanTime();

        return todayAzaan;
      }
    } on HttpException {
      print("http exception");
    }
    return todayAzaan;
  }

  Future getPrayerMethodList() async {
    List<PrayerMethod> list = [];
    try {
      final response = await http.get(Uri.parse('http://api.aladhan.com/v1/methods'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        Map<String, dynamic> data = jsonResponse['data'];

        data.forEach((key, value) {
          PrayerMethod prayerMethod = PrayerMethod(id: value["id"], name: value["name"], code: key);
          list.add(prayerMethod);
        });

        return list;
      }
    } on HttpException {
      print("http exception");
    }
    return list;
  }
}
