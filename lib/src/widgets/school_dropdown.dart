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
  int selected = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);
    selected = azaanBloc.formInputs.school ?? 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Flexible(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Asr Method',
              style: TextStyle(color: textColor, fontSize: textSize),
            ),
          ),
        ),
        Flexible(
          child: DropdownButton<String>(
            dropdownColor: Colors.black,
            autofocus: false,
            focusColor: Colors.transparent,
            value: schools[selected],
            onChanged: (newValue) {
              setState(() {
                if (newValue == "HANAFI") {
                  selected = 1;
                } else {
                  selected = 0;
                }
                azaanBloc.formInputs.school = selected;
              });
            },
            items: schools.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: textColor, fontSize: textSize),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
