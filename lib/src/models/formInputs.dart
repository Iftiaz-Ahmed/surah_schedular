import 'dart:convert';


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

  bool isEmpty() {
    if (address == null) {
      return true;
    } else {
      return false;
    }
  }

}
