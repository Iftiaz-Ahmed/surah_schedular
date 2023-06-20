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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Calculation Method',
            style: TextStyle(color: textColor, fontSize: 18),
          ),
        ),
        FutureBuilder(
          future: azaanBloc.getPrayerMethod(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            List<PrayerMethod> methods = azaanBloc.prayerMethodList ?? [];
            if (selectedMethodId == null && methods.isNotEmpty) {
              selectedMethodId = methods.first.id; // Set the first method's id as the initial value
            }

            return DropdownButton<int>(
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
                    style: const TextStyle(color: textColor),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}