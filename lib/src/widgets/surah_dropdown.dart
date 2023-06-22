import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surah_schedular/src/models/surah.dart';

import '../provider/azaan_bloc.dart';
import '../utils/color_const.dart';

class SurahDropdown extends StatefulWidget {
  final Function(Surah) callback;
  const SurahDropdown({super.key, required this.callback});

  @override
  State<SurahDropdown> createState() => _SurahDropdownState();
}

class _SurahDropdownState extends State<SurahDropdown> {
  int? selectedSurahId;
  late Surah selectedSurah;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);
    azaanBloc.getSurahList().then((value) {
      selectedSurah = value.first;
      widget.callback(selectedSurah);
    });
  }

  @override
  Widget build(BuildContext context) {
    AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Surah',
            style: TextStyle(color: textColor, fontSize: 20),
          ),
        ),
        const SizedBox(
          width: 20,
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

            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: textColor),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: DropdownButton<int>(
                underline: Container(),
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
                      style: const TextStyle(color: textColor, fontSize: 20, overflow: TextOverflow.ellipsis),
                    ),
                    onTap: () {
                      setState(() {
                        selectedSurah = value;
                        widget.callback(selectedSurah);
                      });
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
        // ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.green, // Set the background color
        //     textStyle: const TextStyle(color: textColor), // Set the text color
        //     padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Set the padding
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8.0), // Set the border radius
        //     ),
        //   ),
        //   onPressed: () {
        //     azaanBloc.surahSchedular.addNewSchedule(selectedSurah.name, "22-06-2023", "01:49", 1, selectedSurah.source);
        //   },
        //   child: const Text('Play'),
        // ),
        // ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.orange, // Set the background color
        //     textStyle: const TextStyle(color: textColor), // Set the text color
        //     padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Set the padding
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8.0), // Set the border radius
        //     ),
        //   ),
        //   onPressed: () {
        //     azaanBloc.surahSchedular.resumePlayer();
        //   },
        //   child: const Text('Resume'),
        // ),
      ],
    );
  }
}
