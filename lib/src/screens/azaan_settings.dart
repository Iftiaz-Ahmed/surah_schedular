import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../provider/azaan_bloc.dart';
import '../utils/color_const.dart';

class AzaanSettings extends StatefulWidget {
  const AzaanSettings({Key? key}) : super(key: key);

  @override
  State<AzaanSettings> createState() => _AzaanSettingsState();
}

class _AzaanSettingsState extends State<AzaanSettings> {
  final player = AudioPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);
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
              Flexible(
                child: DropdownButton<String>(
                  dropdownColor: Colors.black,
                  autofocus: false,
                  focusColor: Colors.transparent,
                  value: azaanBloc.selectedAdhan['name'],
                  onChanged: (newValue) async {
                    setState(() {
                      azaanBloc.selectedAdhan['name'] = newValue!;
                      azaanBloc.selectedAdhan['directory'] = "assets/audio/";
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
              Flexible(
                  child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      color: Colors.green,
                      size: textSize + 10,
                    ),
                    onPressed: () {
                      player.play(DeviceFileSource(
                          "${azaanBloc.selectedAdhan['directory']}${azaanBloc.selectedAdhan['name']}"));
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
              ))
            ],
          )),
    );
  }
}
