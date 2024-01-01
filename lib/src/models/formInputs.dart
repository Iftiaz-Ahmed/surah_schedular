import 'dart:convert';

import 'package:localstorage/localstorage.dart';

class FormInputs {
  String? address;
  int? method = 3;
  int? school = 1;

  FormInputs(
      {this.address,
      this.method,
      this.school});

  Map<String, dynamic> toJson() {
    return {
      'address': address,
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
        address = jsonMap['address'];
        method = jsonMap['method'];
        school = jsonMap['school'];
      });
    } catch (e) {}
  }

  bool isEmpty() {
    if (address == null) {
      return true;
    } else {
      return false;
    }
  }

}
