import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:surah_schedular/src/models/surah.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../provider/azaan_bloc.dart';
import '../utils/color_const.dart';
import '../widgets/surah_dropdown.dart';

class ScheduleSurah extends StatefulWidget {
  const ScheduleSurah({Key? key}) : super(key: key);

  @override
  _ScheduleSurahState createState() => _ScheduleSurahState();
}

class _ScheduleSurahState extends State<ScheduleSurah> {
  Surah selectedSurah = Surah(number: 0, name: "", nameMeaning: "", source: "");
  List<String> prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  bool exactTime = true;
  int toggleIndex = 0;
  int whenIndex = 1;
  int prayerIndex = 1;
  int unitIndex = 1;
  int frequencyIndex = 0;
  TextEditingController _timeTextController = TextEditingController();
  TextEditingController _scheduledDate = TextEditingController();
  TextEditingController _scheduledTime = TextEditingController();

  void updateData(Surah newData) {
    setState(() {
      selectedSurah = newData;
    });
  }

  @override
  void initState() {
    super.initState();
    _timeTextController.text = "00";
  }

  @override
  Widget build(BuildContext context) {
    AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Schedule Surah',
          style: TextStyle(color: textColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SurahDropdown(callback: updateData),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Text(
                        'Date',
                        style: TextStyle(color: textColor, fontSize: 20),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Expanded(
                      child: SizedBox(
                        width: 30,
                        child: DateTimePicker(
                          type: DateTimePickerType.date,
                          dateHintText: "Select Date",
                          readOnly: false,
                          cursorColor: textColor,
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: textColor, // Set the desired border color
                                width: 1.0, // Set the border width
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: textColor, // Set the desired border color
                                width: 1.0, // Set the border width
                              ),
                            ),
                          ),
                          style: const TextStyle(color: textColor, fontSize: 20),
                          dateMask: 'd MMM, yyyy',
                          initialValue: DateFormat('dd-MM-yyyy').format(DateTime.now()),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          dateLabelText: 'Date',
                          onChanged: (value) {
                            setState(() {
                              String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(value));
                              _scheduledDate.text = formattedDate;
                            });
                          },
                          validator: (val) {
                            print(val);
                            return null;
                          },
                          onSaved: (val) => print(val),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Exact Time?',
                      style: TextStyle(color: textColor, fontSize: 20),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  ToggleSwitch(
                    activeBgColor: const [Colors.green],
                    inactiveBgColor: bgColor,
                    initialLabelIndex: toggleIndex,
                    totalSwitches: 2,
                    labels: const ['YES', 'NO'],
                    onToggle: (index) {
                      setState(() {
                        _scheduledTime.clear();
                        if (index == 0) {
                          exactTime = true;
                          toggleIndex = index!;
                        } else {
                          exactTime = false;
                          toggleIndex = index!;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              exactTime
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'Time',
                              style: TextStyle(color: textColor, fontSize: 20),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          Expanded(
                            child: DateTimePicker(
                              type: DateTimePickerType.time,
                              readOnly: false,
                              cursorColor: textColor,
                              decoration: const InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: textColor, // Set the desired border color
                                    width: 1.0, // Set the border width
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: textColor, // Set the desired border color
                                    width: 1.0, // Set the border width
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: textColor, fontSize: 20),
                              initialValue: DateFormat('HH:mm').format(DateTime.now()),
                              onChanged: (val) {
                                setState(() {
                                  _scheduledTime.text = val;
                                });
                              },
                              validator: (val) {
                                print(val);
                                return null;
                              },
                              onSaved: (val) => print(val),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${prayers[prayerIndex]} time at ${azaanBloc.todayAzaan.getPrayerTime(prayers[prayerIndex])}",
                          style: const TextStyle(color: textColor, fontSize: 20),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'When?',
                                style: TextStyle(color: textColor, fontSize: 20),
                                textAlign: TextAlign.end,
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            ToggleSwitch(
                              activeBgColor: const [Colors.green],
                              inactiveBgColor: bgColor,
                              initialLabelIndex: whenIndex,
                              totalSwitches: 2,
                              labels: const ['BEFORE', 'AFTER'],
                              onToggle: (index) {
                                setState(() {
                                  if (index == 0) {
                                    whenIndex = index!;
                                  } else {
                                    whenIndex = index!;
                                  }
                                });
                              },
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ToggleSwitch(
                              minWidth: 100,
                              activeBgColor: const [Colors.green],
                              inactiveBgColor: bgColor,
                              initialLabelIndex: prayerIndex,
                              totalSwitches: 5,
                              labels: const ['FAJR', 'DHUHR', 'ASR', 'MAGHRIB', 'ISHA'],
                              onToggle: (index) {
                                setState(() {
                                  if (index == 0) {
                                    prayerIndex = index!;
                                  } else {
                                    prayerIndex = index!;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 50,
                              height: 40,
                              child: TextFormField(
                                style: const TextStyle(fontSize: 20, color: textColor),
                                maxLength: 2,
                                decoration: const InputDecoration(
                                  counterText: "",
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: textColor, // Set the desired border color
                                      width: 1.0, // Set the border width
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: textColor, // Set the desired border color
                                      width: 1.0, // Set the border width
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                cursorColor: textColor,
                                controller: _timeTextController,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            ToggleSwitch(
                              activeBgColor: const [Colors.green],
                              inactiveBgColor: bgColor,
                              initialLabelIndex: unitIndex,
                              totalSwitches: 2,
                              labels: const ['HOUR', 'MINUTE'],
                              onToggle: (index) {
                                setState(() {
                                  if (index == 0) {
                                    unitIndex = index!;
                                  } else {
                                    unitIndex = index!;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Text(
                      'Frequency',
                      style: TextStyle(color: textColor, fontSize: 20),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  ToggleSwitch(
                    activeBgColor: const [Colors.green],
                    inactiveBgColor: bgColor,
                    initialLabelIndex: frequencyIndex,
                    totalSwitches: 3,
                    labels: const ['Once', 'Daily', 'Weekly'],
                    onToggle: (index) {
                      setState(() {
                        if (index == 0) {
                          frequencyIndex = index!;
                        } else {
                          frequencyIndex = index!;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              _scheduledTime.text.isNotEmpty
                  ? Text(
                      "Scheduled at ${_scheduledTime.text} on ${_scheduledDate.text}!!!",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Text(''),
            ],
          ),
        ),
      ),
      floatingActionButton: OutlinedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          textStyle: const TextStyle(color: textColor), // Set the text color
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Set the padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Set the border radius
          ),
        ),
        onPressed: () {
          setState(() {
            if (toggleIndex == 1) {
              _scheduledTime.text = azaanBloc.calculateScheduleTime(prayers[prayerIndex], whenIndex, unitIndex, int.parse(_timeTextController.text));
            }
          });
          print("${selectedSurah.name} - ${selectedSurah.source}");
          azaanBloc.surahSchedular.addNewSchedule(selectedSurah.name, _scheduledDate.text, _scheduledTime.text, 1, selectedSurah.source);
        },
        child: const Text(
          'Schedule',
          style: TextStyle(fontSize: 20, color: textColor),
        ),
      ),
    );
  }
}