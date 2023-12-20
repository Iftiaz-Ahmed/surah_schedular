import 'dart:convert';

import 'package:localstorage/localstorage.dart';

class FormInputs {
  var latitude;
  var longitude;
  var zipcode;
  var city;
  var country;
  int? method = 3;
  int? school = 1;

  FormInputs(
      {this.latitude,
      this.longitude,
      this.zipcode,
      this.city,
      this.country,
      this.method,
      this.school});

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'zipcode': zipcode,
      'city': city,
      'country': country,
      'method': method,
      'school': school
    };
  }

  @override
  String toString() {
    final json = jsonEncode(toJson());
    return json;
  }

  Future<void> retrieveInfo() async {
    try {
      final LocalStorage storage = LocalStorage('surah_schedular.json');
      await storage.ready.then((value) {
        var item = storage.getItem('formInputs');
        final jsonMap = jsonDecode(item) as Map<String, dynamic>;
        latitude = jsonMap['latitude'];
        longitude = jsonMap['longitude'];
        zipcode = jsonMap['zipcode'];
        city = jsonMap['city'];
        country = jsonMap['country'];
        method = jsonMap['method'];
        school = jsonMap['school'];
      });
    } catch (e) {}
  }

  bool isEmpty() {
    if (zipcode == null && city == null && country == null) {
      return true;
    } else {
      return false;
    }
  }

}
