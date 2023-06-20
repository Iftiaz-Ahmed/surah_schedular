class PrayerMethod {
  int id;
  String? name;
  String code;

  PrayerMethod({required this.id, this.name, required this.code});

  void getMethod() {
    print("Code: $code");
    print("Name: $name");
    print("id: $id");
  }
}
