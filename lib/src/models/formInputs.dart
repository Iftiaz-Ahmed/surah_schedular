import 'dart:convert';

import 'package:localstorage/localstorage.dart';

class FormInputs {
  var latitude;
  var longitude;
  var zipcode;
  int? method = 3;
  int? school = 1;

  FormInputs({this.latitude, this.longitude, this.zipcode, this.method, this.school});

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude, 'zipcode': zipcode, 'method': method, 'school': school};
  }

  @override
  String toString() {
    final json = jsonEncode(toJson());
    return json;
  }

  Future<void> saveInfo(String data) async {
    try {
      final LocalStorage storage = LocalStorage('surah_schedular.json');
      await storage.setItem('formInputs', data);
    } catch (e) {}
  }

  Future<void> retrieveInfo() async {
    try {
      final LocalStorage storage = LocalStorage('surah_schedular.json');
      await storage.clear();
      await storage.ready.then((value) {
        String item = storage.getItem('formInputs');
        final jsonMap = jsonDecode(item) as Map<String, dynamic>;
        latitude = jsonMap['latitude'];
        longitude = jsonMap['longitude'];
        zipcode = jsonMap['zipcode'];
        method = jsonMap['method'];
        school = jsonMap['school'];
      });
    } catch (e) {}
  }
}
