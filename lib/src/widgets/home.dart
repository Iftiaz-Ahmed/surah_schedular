import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:surah_schedular/src/screens/azaan_settings.dart';
import 'package:surah_schedular/src/widgets/school_dropdown.dart';
import 'package:window_manager/window_manager.dart';

import '../Components/input_field.dart';
import '../models/formInputs.dart';
import '../provider/azaan_bloc.dart';
import '../screens/schedule_surah.dart';
import '../utils/color_const.dart';
import 'azaan_view.dart';
import 'method_dropdown.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  int count = 0;
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  String deviceName = "";
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _init();
  }

  void _init() async {
    // Add this line to override the default close handler
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> onWindowMinimize() async {
    // await windowManager.hide();
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }

  Future<Map> getSavedAdhanName() async {
    Map adhan = {};
    try {
      final LocalStorage storage = LocalStorage('surah_schedular.json');
      await storage.ready.then((value) {
        adhan = storage.getItem('selectedAdhan');
      });
    } catch (e) {}
    return adhan;
  }

  Future<void> initializeData(context) async {
    if (count == 0) {
      count++;
      AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);

      final FormInputs formInput = azaanBloc.formInputs;
      await formInput.retrieveInfo().then((value) {
        if (!formInput.isEmpty()) {
          _zipController.text = formInput.zipcode ?? '';
          _cityController.text = formInput.city ?? '';
          _countryController.text = formInput.country ?? '';
          azaanBloc.getTodayAzaan(formInput).then((value) {
            azaanBloc.setSchedularTimer();
          });
        }
      });
      await getSavedAdhanName().then((value) {
        if (value.isNotEmpty) {
          azaanBloc.selectedAdhan = value;
        }
      });
      await azaanBloc.getAdhanFileNames();
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeData(context);
    AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);

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
              child: const Text('Schedule Surah'),
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
        height: MediaQuery.of(context).size.height,
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
                      margin: const EdgeInsets.only(right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: 300,
                              child: InputField(
                                hintText: 'Enter zip code',
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    azaanBloc.formInputs.zipcode = value;
                                  });
                                },
                                controller: _zipController,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: 300,
                              child: InputField(
                                hintText: 'Enter City',
                                keyboardType: TextInputType.text,
                                onChanged: (value) {
                                  setState(() {
                                    azaanBloc.formInputs.city = value;
                                  });
                                },
                                controller: _cityController,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: 300,
                              child: InputField(
                                hintText: 'Enter Country',
                                keyboardType: TextInputType.text,
                                onChanged: (value) {
                                  setState(() {
                                    azaanBloc.formInputs.country = value;
                                  });
                                },
                                controller: _countryController,
                              ),
                            ),
                          ),
                          const Expanded(flex: 2, child: MethodDropdown()),
                          const Expanded(flex: 2, child: SchoolDropdown()),
                          const Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 10,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green, // Set the background color
                                textStyle: const TextStyle(
                                    color: textColor,
                                    fontSize: 18), // Set the text color
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0.0,
                                    horizontal: 20.0), // Set the padding
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Set the border radius
                                ),
                              ),
                              onPressed: () {
                                azaanBloc
                                    .getLatLng(azaanBloc.formInputs)
                                    .then((value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      azaanBloc.formInputs.latitude = value[0];
                                      azaanBloc.formInputs.longitude = value[1];
                                      azaanBloc.formInputs.city = value[2];
                                      azaanBloc.formInputs.country = value[3];
                                      _cityController.text = value[2];
                                      _countryController.text = value[3];
                                    });
                                  }
                                  azaanBloc.formInputs.method =
                                      azaanBloc.formInputs.method ?? 2;
                                  azaanBloc.formInputs.school =
                                      azaanBloc.formInputs.school ?? 1;
                                  azaanBloc
                                      .getTodayAzaan(azaanBloc.formInputs)
                                      .then((value) {
                                    azaanBloc.setSchedularTimer();
                                    azaanBloc.formInputs.saveInfo(
                                        azaanBloc.formInputs.toString());
                                  });
                                });
                              },
                              child: const Text('Save Settings'),
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: Container(),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Expanded(
            //     flex: 1,
            //     child: Row(
            //       children: [
            //         ElevatedButton(
            //             onPressed: () async {
            //               print('Looking for ChromeCast devices...');
            //
            //               // try {
            //               List<find_chromecast.CastDevice> devices =
            //               await find_chromecast.find_chromecasts();
            //               if (devices.isNotEmpty) {
            //                 find_chromecast.CastDevice device = devices.first;
            //                 print(device.name);
            //                 final CastDevice castDevice = CastDevice(
            //                   host: device.ip,
            //                   port: device.port,
            //                   type: '_googlecast._tcp',
            //                 );
            //                 CastSender castSender = CastSender(castDevice);
            //                 await castSender.connect();
            //                 // Connection successful
            //                 print("Connection Successfull!");
            //
            //                 castSender.launch();
            //                 List<CastMedia> mediaList = [
            //                   CastMedia(
            //                     contentId:
            //                     "https://cdn.islamic.network/quran/audio/128/ar.alafasy/6231.mp3",
            //                     contentType: 'audio/mp3',
            //                   ),
            //                 ];
            //
            //                 castSender.loadPlaylist(mediaList);
            //               } else {
            //                 // No devices found
            //                 print("Connection Unsuccessfull!");
            //               }
            //               // } catch (e) {
            //               //   print(e);
            //               //   setState(() {
            //               //     deviceName = e.toString();
            //               //   });
            //               // }
            //             },
            //             child: Text('Click')),
            //         ElevatedButton(
            //             onPressed: () {
            //               player.play(UrlSource(
            //                   "https://cdn.islamic.network/quran/audio/128/ar.alafasy/6231.mp3"));
            //             },
            //             child: Text('Play')),
            //         ElevatedButton(
            //             onPressed: () {
            //               player.pause();
            //             },
            //             child: Text('Pause')),
            //       ],
            //     )),
            // Text(
            //   deviceName,
            //   style: TextStyle(color: textColor),
            // )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
