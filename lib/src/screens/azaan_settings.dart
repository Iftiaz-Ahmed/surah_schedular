import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:provider/provider.dart';
import 'package:surah_schedular/src/models/adhan.dart';
import 'package:surah_schedular/src/models/task.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../provider/azaan_bloc.dart';
import '../utils/color_const.dart';
import '../widgets/castAudio.dart';

class AzaanSettings extends StatefulWidget {
  const AzaanSettings({Key? key}) : super(key: key);

  @override
  State<AzaanSettings> createState() => _AzaanSettingsState();
}

class _AzaanSettingsState extends State<AzaanSettings> {
  final player = AudioPlayer();
  int count = 0;
  int type = 0;
  List<PlatformFile>? _audioFiles;
  double maxValue = 50.0;
  int prayerIndex = 0;
  int playback = 0;

  @override
  void initState() {
    super.initState();
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
          azaanBloc.selectedAdhan = AdhanItem(
              name: _audioFiles!.first.name.toString(),
              path: _audioFiles!.first.path.toString(),
              type: 0);
        });

        azaanBloc.saveDataLocally("settings");
      }
    } catch (e) {
      print("Error picking audio files: $e");
    }
  }

  void initialize(AzaanBloc azaanBloc) {
    if (count == 0) {
      setState(() {
        playback = azaanBloc.castConnected ? 1 : 0;
      });
      count++;
      type = azaanBloc.selectedAdhan.type;
      maxValue = azaanBloc.azaanVolumes[0];
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
          "Azaan Settings",
          style: TextStyle(color: textColor),
        ),
      ),
      body: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose Azaan",
                style: TextStyle(color: textColor, fontSize: textSize + 5),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: ToggleSwitch(
                  activeBgColor: const [Colors.green],
                  inactiveBgColor: bgColor,
                  initialLabelIndex: type,
                  totalSwitches: 2,
                  labels: const ['Custom', 'Library'],
                  onToggle: (index) {
                    setState(() {
                      type = index!;
                      if (type == 1) {
                        if (azaanBloc.selectedAdhan.type == 0) {
                          azaanBloc.selectedAdhan = azaanBloc.adhanList[11];
                        }
                      }
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              type == 1
                  ? Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: DropdownButton<AdhanItem>(
                          style: const TextStyle(
                              color: textColor, fontSize: textSize),
                          dropdownColor: Colors.black,
                          autofocus: false,
                          focusColor: Colors.transparent,
                          value: azaanBloc.selectedAdhan,
                          onChanged: (newValue) async {
                            setState(() {
                              azaanBloc.selectedAdhan = newValue!;
                            });

                            azaanBloc.saveDataLocally("settings");
                          },
                          items: azaanBloc.adhanList
                              .map<DropdownMenuItem<AdhanItem>>(
                                  (AdhanItem value) {
                            return DropdownMenuItem<AdhanItem>(
                              value: value,
                              child: Text(
                                value.name.toString(),
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: textSize,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  : Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                                  'Select Azaan File',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: textSize - 2),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            azaanBloc.selectedAdhan.type == 0
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(azaanBloc.selectedAdhan.name,
                                        style: const TextStyle(
                                            color: textColor,
                                            fontSize: textSize - 4)),
                                  )
                                : const Text('')
                          ],
                        ),
                      ),
                    ),
              Flexible(
                  child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.green,
                        size: textSize + 10,
                      ),
                      onPressed: () async {
                        print(azaanBloc.selectedAdhan);
                        await FlutterVolumeController.setVolume(maxValue / 100);
                        player.setVolume(maxValue / 100);
                        if (azaanBloc.castConnected) {
                          azaanBloc.sendMessagePlayAudio(Task(
                              name: "Adhan",
                              date: "",
                              time: "",
                              taskTimer:
                                  Timer(const Duration(seconds: 0), () {}),
                              frequency: 0,
                              sourceType: 0,
                              isSurah: false,
                              source: azaanBloc.selectedAdhan.path,
                              volume: maxValue / 100, timeString: ""));
                        } else {
                          if (azaanBloc.selectedAdhan.type == 1) {
                            player
                                .play(UrlSource(azaanBloc.selectedAdhan.path));
                          } else {
                            player.play(
                                DeviceFileSource(azaanBloc.selectedAdhan.path));
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.stop,
                        color: Colors.red,
                        size: textSize + 10,
                      ),
                      onPressed: () {
                        if (azaanBloc.castConnected) {
                          azaanBloc.pauseCastAudio();
                        } else {
                          player.stop();
                        }
                      },
                    ),
                  ],
                ),
              )),
              Row(
                children: [
                  Checkbox(
                    value: azaanBloc.playDua,
                    activeColor: Colors.green,
                    onChanged: (bool? value) {
                      setState(() {
                        azaanBloc.playDua = value!;
                      });
                    },
                  ),
                  const Text('Play Dua after Adhaan', style: TextStyle(color: textColor),),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Set Volumes",
                style: TextStyle(color: textColor, fontSize: textSize + 5),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                child: ToggleSwitch(
                  minWidth: 100,
                  activeBgColor: const [Colors.green],
                  inactiveBgColor: bgColor,
                  initialLabelIndex: prayerIndex,
                  totalSwitches: 5,
                  labels: const ['FAJR', 'DHUHR', 'ASR', 'MAGHRIB', 'ISHA'],
                  onToggle: (index) {
                    setState(() {
                      prayerIndex = index!;
                      maxValue = azaanBloc.azaanVolumes[prayerIndex];
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Flexible(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Slider(
                        label: maxValue.toString(),
                        thumbColor: textColor,
                        activeColor: textColor,
                        value: maxValue,
                        min: 0,
                        max: 100,
                        divisions: 10,
                        onChanged: (double value) async {
                          setState(() {
                            maxValue = value;
                            azaanBloc.azaanVolumes[prayerIndex] = maxValue;
                          });

                          azaanBloc.saveDataLocally("settings");
                        },
                      ),
                    ),
                  ),
                  Flexible(
                      child: Text(
                    "${maxValue.toInt()}%",
                    style:
                        const TextStyle(color: textColor, fontSize: textSize),
                  )),
                ],
              ),
              const Text(
                "Set Playback",
                style: TextStyle(color: textColor, fontSize: textSize + 5),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                child: ToggleSwitch(
                  activeBgColor: const [Colors.green],
                  inactiveBgColor: bgColor,
                  initialLabelIndex: playback,
                  totalSwitches: 2,
                  labels: const ['Device', 'Cast'],
                  onToggle: (index) {
                    setState(() {
                      playback = index!;
                    });
                  },
                ),
              ),
              if (playback == 1) const CastAudio()
            ],
          )),
    );
  }
}
