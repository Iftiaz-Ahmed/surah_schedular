import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../provider/azaan_bloc.dart';
import '../utils/color_const.dart';

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
  String defaultAdhan = "";
  double maxValue = 50.0;
  int prayerIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
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
          azaanBloc.selectedAdhan['name'] = _audioFiles?.first.name;
          azaanBloc.selectedAdhan['path'] = _audioFiles?.first.path;
          azaanBloc.selectedAdhan['type'] = 1;
        });

        final LocalStorage storage = LocalStorage('surah_schedular.json');
        await storage.setItem('selectedAdhan', azaanBloc.selectedAdhan);
      }
    } catch (e) {
      print("Error picking audio files: $e");
    }
  }

  void initialize(AzaanBloc azaanBloc) {
    if (count == 0) {
      count++;

      type = azaanBloc.selectedAdhan['type'];
      if (type == 0) {
        defaultAdhan = azaanBloc.selectedAdhan['name'];
      } else {
        defaultAdhan = azaanBloc.adhanList[0];
      }
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
                  labels: const ['Library', 'Custom'],
                  onToggle: (index) {
                    setState(() {
                      type = index!;
                      if (type == 0) {
                        if (azaanBloc.selectedAdhan['type'] == 0) {
                          defaultAdhan = azaanBloc.selectedAdhan['name'] ??
                              azaanBloc.adhanList[0];
                        } else {
                          defaultAdhan = azaanBloc.adhanList[0];
                        }
                      }
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              type == 0
                  ? Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: DropdownButton<String>(
                          style: const TextStyle(
                              color: textColor, fontSize: textSize),
                          dropdownColor: Colors.black,
                          autofocus: false,
                          focusColor: Colors.transparent,
                          value: defaultAdhan,
                          onChanged: (newValue) async {
                            setState(() {
                              defaultAdhan = newValue!;
                              azaanBloc.selectedAdhan['name'] = newValue!;
                              azaanBloc.selectedAdhan['path'] =
                                  "assets/audio/$newValue";
                              azaanBloc.selectedAdhan['type'] = 0;
                            });

                            final LocalStorage storage =
                                LocalStorage('surah_schedular.json');
                            await storage.setItem(
                                'selectedAdhan', azaanBloc.selectedAdhan);
                          },
                          items: azaanBloc.adhanList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                    color: textColor, fontSize: textSize),
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
                            azaanBloc.selectedAdhan['type'] == 1
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(azaanBloc.selectedAdhan['name'],
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
                      onPressed: () {
                        player.setVolume(maxValue / 100);
                        player.play(
                            DeviceFileSource(azaanBloc.selectedAdhan['path']));
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.stop,
                        color: Colors.red,
                        size: textSize + 10,
                      ),
                      onPressed: () {
                        player.stop();
                      },
                    ),
                  ],
                ),
              )),
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Set Volumes",
                style: TextStyle(color: textColor, fontSize: textSize + 5),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 20.0),
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

                          try {
                            final LocalStorage storage =
                                LocalStorage('surah_schedular.json');
                            await storage.setItem(
                                'azaanVolumes', azaanBloc.azaanVolumes);
                          } catch (e) {}
                        },
                      ),
                    ),
                  ),
                  Flexible(
                      child: Text(
                    "${maxValue.toInt()}%",
                    style:
                        const TextStyle(color: textColor, fontSize: textSize),
                  ))
                ],
              ),
            ],
          )),
    );
  }
}
