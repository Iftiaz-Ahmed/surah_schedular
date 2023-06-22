import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surah_schedular/src/models/surah.dart';

import '../provider/azaan_bloc.dart';
import '../utils/color_const.dart';

class SurahDropdown extends StatefulWidget {
  const SurahDropdown({Key? key}) : super(key: key);

  @override
  State<SurahDropdown> createState() => _SurahDropdownState();
}

class _SurahDropdownState extends State<SurahDropdown> {
  int? selectedSurahId;
  late Surah selectedSurah;

  @override
  Widget build(BuildContext context) {
    AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Surah',
            style: TextStyle(color: textColor, fontSize: 18),
          ),
        ),
        FutureBuilder(
          future: azaanBloc.getSurahList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            List<Surah> surahList = azaanBloc.surahList ?? [];
            if (selectedSurahId == null && surahList.isNotEmpty) {
              selectedSurahId = surahList.first.number;
              selectedSurah = surahList.first;
            }

            return DropdownButton<int>(
              dropdownColor: Colors.black,
              autofocus: false,
              focusColor: Colors.transparent,
              value: selectedSurahId,
              onChanged: (newValue) {
                setState(() {
                  if (newValue != null) {
                    selectedSurahId = newValue;
                    print(selectedSurahId);
                  }
                });
              },
              items: surahList.map<DropdownMenuItem<int>>((Surah value) {
                return DropdownMenuItem<int>(
                  value: value.number,
                  child: Text(
                    "${value.number}. ${value.name} - ${value.nameMeaning}",
                    style: const TextStyle(color: textColor),
                  ),
                  onTap: () {
                    setState(() {
                      selectedSurah = value;
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Set the background color
            textStyle: const TextStyle(color: textColor), // Set the text color
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Set the padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Set the border radius
            ),
          ),
          onPressed: () {
            azaanBloc.surahSchedular.addNewSchedule(selectedSurah.name, "22-06-2023", "01:49", 1, selectedSurah.source);
          },
          child: const Text('Play'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, // Set the background color
            textStyle: const TextStyle(color: textColor), // Set the text color
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Set the padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Set the border radius
            ),
          ),
          onPressed: () {
            azaanBloc.surahSchedular.resumePlayer();
          },
          child: const Text('Resume'),
        ),
      ],
    );
  }
}
