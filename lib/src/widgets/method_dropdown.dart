import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surah_schedular/src/models/prayerMethod.dart';

import '../provider/azaan_bloc.dart';
import '../utils/color_const.dart';

class MethodDropdown extends StatefulWidget {
  const MethodDropdown({Key? key}) : super(key: key);

  @override
  State<MethodDropdown> createState() => _MethodDropdownState();
}

class _MethodDropdownState extends State<MethodDropdown> {
  int? selectedMethodId;

  @override
  Widget build(BuildContext context) {
    AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Flexible(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Calculation Method',
              style: TextStyle(color: textColor, fontSize: textSize),
            ),
          ),
        ),
        Flexible(
          child: FutureBuilder(
            future: azaanBloc.getPrayerMethod(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              List<PrayerMethod> methods = azaanBloc.prayerMethodList ?? [];
              if (selectedMethodId == null && methods.isNotEmpty) {
                print(azaanBloc.formInputs.method);
                selectedMethodId = azaanBloc.formInputs.method;
              }

              return DropdownButton<int>(
                dropdownColor: Colors.black,
                autofocus: false,
                focusColor: Colors.transparent,
                value: selectedMethodId,
                onChanged: (newValue) {
                  setState(() {
                    if (newValue != null) {
                      selectedMethodId = newValue;
                      azaanBloc.formInputs.method = newValue;
                    }
                  });
                },
                items: methods.map<DropdownMenuItem<int>>((PrayerMethod value) {
                  return DropdownMenuItem<int>(
                    value: value.id,
                    child: Text(
                      value.code.toString(),
                      style:
                          const TextStyle(color: textColor, fontSize: textSize),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
