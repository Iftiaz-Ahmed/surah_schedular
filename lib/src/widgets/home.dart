import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cast/device.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surah_schedular/src/screens/azaan_settings.dart';
import 'package:surah_schedular/src/widgets/school_dropdown.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../Components/input_field.dart';
import '../models/adhan.dart';
import '../models/formInputs.dart';
import '../provider/azaan_bloc.dart';
import '../screens/schedule_surah.dart';
import '../utils/color_const.dart';
import 'azaan_view.dart';
import 'method_dropdown.dart';
import 'package:surah_schedular/src/models/schedular.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:surah_schedular/src/models/localData.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with WindowListener, TrayListener {
  int count = 0;
  String deviceName = "";
  final player = AudioPlayer();
  final _addressController = TextEditingController();
  String installationDirectory = "";
  Map<String, dynamic> savedFileData = {};

  @override
  void initState() {
    super.initState();

    windowManager.addListener(this);
    trayManager.addListener(this);
    _init();
  }

  void _init() async {
    await windowManager.setPreventClose(true);
    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/images/tray_icon.ico'
          : 'assets/images/tray_icon.png',
    );
    setState(() {});
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> onWindowMinimize() async {
    await windowManager.hide();
  }

  @override
  void onTrayIconMouseDown() async {
    bool isVisible = await windowManager.isVisible();
    if (!isVisible) {
      windowManager.restore();
      await windowManager.show();
    } else {
      await windowManager.focus();
    }
    setState(() {});
  }

  Future getSavedData() async {
    LocalData localData = LocalData();
    savedFileData = await localData.readJsonFile(installationDirectory);
  }


  void scheduleDailyFunctionExecution(
      AzaanBloc azaanBloc, BuildContext context) {
    DateTime now = DateTime.now();
    DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
    Duration durationUntilMidnight = nextMidnight.difference(now);
    if (!durationUntilMidnight.isNegative) {
      Timer(durationUntilMidnight, () {
        count = 0;
        print("Executing functions at 12:00 AM");
        initializeData(azaanBloc, context);
      });
    }
  }

  CastDevice getCastDevice(var item) {
    CastDevice device =
        CastDevice(serviceName: "", name: "", host: "", port: 0);

    if (item!=null) {
      device.serviceName = item['serviceName'];
      device.name = item['name'];
      device.port = item['port'];
      device.host = item['host'];
      if (item['extras'] is Map<String, String>) {
        device.extras = item['extras'];
      }
    }

    return device;
  }

  Future<void> initializeData(AzaanBloc azaanBloc, BuildContext context) async {
    if (count == 0) {
      count++;
      installationDirectory = azaanBloc.getInstallationDirectory();

      await azaanBloc.getAdhanFileNames();
      await getSavedData().then((value) {
        final FormInputs formInput = azaanBloc.formInputs;

        //retrieving selected Adhan
        azaanBloc.selectedAdhan = AdhanItem.fromJson(savedFileData['selectedAdhan']);

        // retrieving formInputs
        if (savedFileData['formInputs'] != null) {
          final jsonMap = jsonDecode(savedFileData['formInputs']) as Map<String, dynamic>;
          formInput.address = jsonMap['address'];
          formInput.method = jsonMap['method'];
          formInput.school = jsonMap['school'];
        }

        if (!formInput.isEmpty()) {
          _addressController.text = formInput.address ?? '';
          azaanBloc.getTodayAzaan(formInput).then((value) {
            azaanBloc.setAzaanTimes(azaanBloc.selectedAdhan.path);
            azaanBloc.schedular.retrieveTasks();
          });
        }

        // retrieving azaan volumes
        azaanBloc.azaanVolumes = savedFileData['azaanVolumes'];

        //retrieving castDevice
        azaanBloc.castDevice = getCastDevice(savedFileData['castDevice']);
        if (azaanBloc.castDevice.name.isNotEmpty) {
          setState(() {
            azaanBloc.castConnected = true;
          });
        }

      });

      scheduleDailyFunctionExecution(azaanBloc, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);
    initializeData(azaanBloc, context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            widget.title,
            style: const TextStyle(color: textColor),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColor, // Set the background color
                  textStyle:
                      const TextStyle(color: textColor), // Set the text color
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0), // Set the padding
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Set the border radius
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ScheduleSurah()),
                  );
                },
                child: const Text(
                  'Schedule Surah',
                  style: TextStyle(color: textColor),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: IconButton(
          icon: const Icon(
            Icons.settings,
            color: textColor,
            size: textSize + 10,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AzaanSettings()),
            );
          },
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: 700,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Expanded(flex: 7, child: AzaanView()),
                    Expanded(
                      flex: 6,
                      child: Container(
                        margin: const EdgeInsets.only(top: 40, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 550,
                              child: CustomTextField(
                                borderRadius: 10,
                                maxLines: 1,
                                fontSize: textSize,
                                textColor: textColor,
                                fillColor: bgColor.withOpacity(0.1),
                                hintText: "Enter your address",
                                textController: _addressController,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapBoxAutoCompleteWidget(
                                        apiKey: "pk.eyJ1IjoiaWZ0aWF6MDMiLCJhIjoiY2xxa2poYnMxMXV1YTJrcHEwbmRzaTNkdiJ9.U6pgvF6GW4uefRJZT4hZFQ",
                                        hint: "Enter your address",
                                        onSelect: (place) {
                                          if (place!= null) {
                                            _addressController.text = place.placeName!;
                                          }
                                        },
                                        limit: 5,
                                        country: "US",
                                        textColor: textColor,
                                        fontSize: textSize,
                                      ),
                                    ),
                                  );
                                },
                                enabled: true,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            const Flexible(child: MethodDropdown()),
                            SizedBox(
                              height: 10,
                            ),
                            const Flexible(child: SchoolDropdown()),
                            SizedBox(
                              height: 30,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 30.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Set the border radius
                                ),
                              ),
                              onPressed: () {
                                azaanBloc.formInputs.address = _addressController.text;
                                azaanBloc.formInputs.method =
                                    azaanBloc.formInputs.method ?? 2;
                                azaanBloc.formInputs.school =
                                    azaanBloc.formInputs.school ?? 1;
                                azaanBloc
                                    .getTodayAzaan(azaanBloc.formInputs)
                                    .then((value) {
                                  azaanBloc.setAzaanTimes(
                                      azaanBloc.selectedAdhan.path);
                                  azaanBloc.saveDataLocally("home");
                                });
                              },
                              child: const Text('Save Settings', style: TextStyle(color: textColor, fontSize: 18),),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Are you sure you want to close this window?'),
            actions: [
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
