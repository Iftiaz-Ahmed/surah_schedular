import 'package:date_time_picker/date_time_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:surah_schedular/src/models/surah.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../Components/input_field.dart';
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
  Surah selectedAudio = Surah(number: 0, name: "", nameMeaning: "", source: "");
  List<String> prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  List<String> frequency = ['Once', 'Daily', 'Weekly'];
  bool exactTime = true;
  int surahSource = 1; // from selected list
  int toggleIndex = 0;
  int whenIndex = 1;
  int prayerIndex = 1;
  int unitIndex = 1;
  int frequencyIndex = 0;
  double volume = 80.0;
  List surahList = [];
  int count = 0;
  TextEditingController _timeTextController = TextEditingController();
  TextEditingController _scheduledDate = TextEditingController();
  TextEditingController _scheduledTime = TextEditingController();
  TextEditingController _link = TextEditingController();
  List<PlatformFile>? _audioFiles;

  void updateData(Surah newData) {
    setState(() {
      selectedSurah = newData;
    });
  }

  @override
  void initState() {
    super.initState();
    _timeTextController.text = "10";
    _scheduledDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _scheduledTime.text = DateFormat('HH:mm').format(DateTime.now());
  }

  void initialize(AzaanBloc azaanBloc) {
    if (count == 0) {
      count++;
      surahList.clear();
      for (int i = 0; i < azaanBloc.schedular.tasks.length; i++) {
        if (azaanBloc.schedular.tasks[i].isSurah) {
          Map data = {"task": azaanBloc.schedular.tasks[i], "index": i};
          surahList.add(data);
        }
      }
    }
  }

  String convertTo12hrFormat(String time24hr) {
    List<String> parts = time24hr.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    String period = (hours < 12) ? 'AM' : 'PM';

    hours = hours % 12;
    hours = (hours == 0) ? 12 : hours;

    String time12hr = '$hours:${minutes.toString().padLeft(2, '0')} $period';

    return time12hr;
  }

  Future<void> _pickAudioFiles(AzaanBloc azaanBloc) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _audioFiles = result.files;
          print(_audioFiles?.first.name);

          selectedAudio.number = 200;
          selectedAudio.name = _audioFiles!.first.name.toString();
          selectedAudio.source = _audioFiles!.first.path.toString();
          selectedAudio.nameMeaning = 'custom';
        });
      }
    } catch (e) {
      print("Error picking audio files: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);
    initialize(azaanBloc);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Schedule Surah',
          style: TextStyle(color: textColor),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
                child: surahList.length > 0
                    ? Container(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                      itemCount: surahList.length ?? 0,
                      itemBuilder: (context, index) {
                        return ListTile(
                          dense: true,
                          horizontalTitleGap: 20,
                          minLeadingWidth: 2,
                          leading: Text(
                            "${index + 1}",
                            style: const TextStyle(color: textColor, fontSize: 14),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 2,
                                child: Text(
                                  surahList[index]['task'].name,
                                  style: const TextStyle(
                                      color: textColor,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              const SizedBox(width: 15,),
                              Text("Frequency: ${frequency[
                                surahList[index]['task'].frequency]}", style: const TextStyle(
                                    color: textColor,
                                    overflow: TextOverflow.ellipsis),),
                              const SizedBox(width: 15,),
                              Flexible(
                                child: Text(
                                  "${surahList[index]['task'].volume.toInt()}%",
                                  style: const TextStyle(
                                      color: textColor,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 2,
                                child: Text(
                                  surahList[index]['task'].date,
                                  style: const TextStyle(
                                      color: textColor,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              const SizedBox(width: 5,),
                              Text(
                                surahList[index]['task'].timeString.toString().isEmpty ?
                                convertTo12hrFormat(surahList[index]['task'].time)
                                    :surahList[index]['task'].timeString,
                                style: const TextStyle(
                                    color: textColor,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                azaanBloc.schedular.deleteTask(
                                    surahList[index]['index']);
                                count = 0; // required to update data
                              });
                              if (azaanBloc.castConnected) {
                                azaanBloc.pauseCastAudio();
                              }
                            },
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.red,
                            ),
                          ),
                        );
                      }),
                )
                    : Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 15),
                  padding: const EdgeInsets.all(15.0),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width / 5,
                  child: const Center(
                    child: Text(
                      "No Surah Scheduled!",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: textSize + 2,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                )),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: ToggleSwitch(
                      activeBgColor: const [Colors.green],
                      inactiveBgColor: bgColor,
                      initialLabelIndex: surahSource,
                      totalSwitches: 3,
                      labels: const ['Custom', 'Library', 'Link'],
                      onToggle: (index) {
                        setState(() {
                          surahSource = index!;
                        });
                      },
                    ),
                  ),
                  if (surahSource == 1 )
                  SizedBox(
                      height: 70, child: SurahDropdown(callback: updateData))
                  else if (surahSource == 0)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          selectedAudio.nameMeaning == "custom"
                              ? Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(selectedAudio.name,
                                style: const TextStyle(
                                    color: textColor,
                                    fontSize: textSize - 4)),
                          )
                              : const Text(''),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color:
                                    Colors.green), // Set the border color
                                backgroundColor: Colors
                                    .transparent, // Set the background color// Set the padding
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Set the border radius
                                ),
                              ),
                              onPressed: () {
                                _pickAudioFiles(azaanBloc);
                              },
                              child: const Text(
                                'Select Audio File',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: textSize - 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  else if (surahSource == 2)
                    SizedBox(
                      width: 500,
                      child: InputField(
                        controller: _link,
                        hintText: "https://download.quranicaudio.com/quran/abdulbaset_mujawwad/112.mp3",
                        onChanged: (value) {
                          selectedAudio.number = 201;
                          selectedAudio.name = "Custom Link";
                          selectedAudio.source = _link.text;
                          selectedAudio.nameMeaning = "link";
                        },
                      ),
                    ),
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
                            style:
                            TextStyle(color: textColor, fontSize: textSize),
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
                                    color:
                                    textColor, // Set the desired border color
                                    width: 1.0, // Set the border width
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                    textColor, // Set the desired border color
                                    width: 1.0, // Set the border width
                                  ),
                                ),
                              ),
                              style: const TextStyle(
                                  color: textColor, fontSize: textSize),
                              dateMask: 'd MMM, yyyy',
                              initialValue: _scheduledDate.text,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              dateLabelText: 'Date',
                              onChanged: (value) {
                                setState(() {
                                  String formattedDate =
                                  DateFormat('dd-MM-yyyy')
                                      .format(DateTime.parse(value));
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
                          style:
                          TextStyle(color: textColor, fontSize: textSize),
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
                            style: TextStyle(
                                color: textColor, fontSize: textSize),
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
                                  color:
                                  textColor, // Set the desired border color
                                  width: 1.0, // Set the border width
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                  textColor, // Set the desired border color
                                  width: 1.0, // Set the border width
                                ),
                              ),
                            ),
                            style: const TextStyle(
                                color: textColor, fontSize: textSize),
                            initialValue: _scheduledTime.text,
                            onChanged: (val) {
                              setState(() {
                                _scheduledTime.text = val;
                                print(_scheduledTime.text);
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
                        "${prayers[prayerIndex]} time at ${convertTo12hrFormat(azaanBloc.todayAzaan.getPrayerTime(prayers[prayerIndex]))}",
                        style: const TextStyle(
                            color: textColor, fontSize: textSize),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'When?',
                              style: TextStyle(
                                  color: textColor, fontSize: textSize),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          const SizedBox(
                            width: 3,
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
                            labels: const [
                              'FAJR',
                              'DHUHR',
                              'ASR',
                              'MAGHRIB',
                              'ISHA'
                            ],
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
                              style: const TextStyle(
                                  fontSize: textSize, color: textColor),
                              maxLength: 2,
                              decoration: const InputDecoration(
                                counterText: "",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 10),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                    textColor, // Set the desired border color
                                    width: 1.0, // Set the border width
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                    textColor, // Set the desired border color
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
                            width: 10,
                          ),
                          ToggleSwitch(
                            minWidth: 80,
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
                          style:
                          TextStyle(color: textColor, fontSize: textSize),
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
                        labels: frequency,
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
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Flexible(
                          child: Text(
                            "Volume",
                            style: TextStyle(color: textColor, fontSize: textSize),
                          )),
                      Flexible(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Slider(
                            label: volume.toString(),
                            thumbColor: textColor,
                            activeColor: textColor,
                            value: volume,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            onChanged: (double value) async {
                              setState(() {
                                volume = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: OutlinedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          textStyle: const TextStyle(color: textColor), // Set the text color
          padding: const EdgeInsets.symmetric(
              vertical: 16.0, horizontal: 24.0), // Set the padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Set the border radius
          ),
        ),
        onPressed: () {
          String timeString = "";
          if (!exactTime) {
            if (whenIndex == 0) {
              timeString = unitIndex==0 ? "${_timeTextController.text} hour/s before ${prayers[prayerIndex]}" : "${_timeTextController.text} minute/s before ${prayers[prayerIndex]}";
            } else {
              timeString = unitIndex==0 ? "${_timeTextController.text} hour/s after ${prayers[prayerIndex]}" : "${_timeTextController.text} minute/s after ${prayers[prayerIndex]}";
            }
          }
          setState(() {
            count = 0; // required to update data
            if (toggleIndex == 1) {
              _scheduledTime.text = azaanBloc.calculateScheduleTime(
                  prayers[prayerIndex],
                  whenIndex,
                  unitIndex,
                  int.parse(_timeTextController.text)).toString();
            }
          });

          if (surahSource == 1) {
            // for library
          azaanBloc.schedular.addNewSchedule(
              selectedSurah.name,
              _scheduledDate.text,
              _scheduledTime.text,
              surahSource,
              selectedSurah.source,
              frequencyIndex,
              volume,
              true, timeString);
          } else {
            // for custom and url
            azaanBloc.schedular.addNewSchedule(
                selectedAudio.name,
                _scheduledDate.text,
                _scheduledTime.text,
                surahSource,
                selectedAudio.source,
                frequencyIndex,
                volume,
                true, timeString);
          }

          setState(() {
            surahSource = 1;
          });
        },
        child: const Text(
          'Schedule',
          style: TextStyle(fontSize: textSize, color: textColor),
        ),
      ),
    );
  }
}
