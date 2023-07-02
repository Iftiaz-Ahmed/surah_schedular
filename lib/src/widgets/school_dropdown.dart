import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/azaan_bloc.dart';
import '../utils/color_const.dart';

class SchoolDropdown extends StatefulWidget {
  const SchoolDropdown({Key? key}) : super(key: key);

  @override
  State<SchoolDropdown> createState() => _SchoolDropdownState();
}

class _SchoolDropdownState extends State<SchoolDropdown> {
  List<String> schools = ['SHAFI', 'HANAFI'];
  String selected = 'HANAFI';

  @override
  Widget build(BuildContext context) {
    AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);
    if (azaanBloc.formInputs.school == 1) {
      selected = 'HANAFI';
    } else {
      selected = 'SHAFI';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Asr Method',
            style: TextStyle(color: textColor, fontSize: 18),
          ),
        ),
        DropdownButton<String>(
          dropdownColor: Colors.black,
          autofocus: false,
          focusColor: Colors.transparent,
          value: selected,
          onChanged: (newValue) {
            setState(() {
              selected = newValue!;
              if (selected == "HANAFI") {
                azaanBloc.formInputs.school = 1;
              } else {
                azaanBloc.formInputs.school = 0;
              }
            });
          },
          items: schools.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(color: textColor),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
