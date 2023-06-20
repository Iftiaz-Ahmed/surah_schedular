class TodayAzaan {
  String? date;
  Map<String, String>? prayerTimes;
  String? gregorianDate;

  TodayAzaan({this.date, this.prayerTimes, this.gregorianDate});

  void getAzaanTime() {
    print("Date: $date");
    print(prayerTimes);
    print(gregorianDate);
  }
}
