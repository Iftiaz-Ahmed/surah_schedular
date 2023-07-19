import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surah_schedular/src/widgets/school_dropdown.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  int count = 0;
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  String deviceName = "";
  final player = AudioPlayer();

  Future<void> initializeData(context) async {
    if (count == 0) {
      count++;
      AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);
      final FormInputs formInput = azaanBloc.formInputs;
      await formInput.retrieveInfo().then((value) {
        _zipController.text = formInput.zipcode ?? '';
        _cityController.text = formInput.city ?? '';
        _countryController.text = formInput.country ?? '';
        azaanBloc.getTodayAzaan(formInput).then((value) {
          azaanBloc.setSchedularTimer();
        });
      });
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
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AzaanView(),
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
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
                        Container(
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
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: 300,
                          child: InputField(
                            hintText: 'Enter Country',
                            keyboardType: TextInputType.text,
                            onChanged: (value) {
                              setState(() {
                                azaanBloc.formInputs.city = value;
                              });
                            },
                            controller: _countryController,
                          ),
                        ),
                        const MethodDropdown(),
                        const SchoolDropdown(),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green, // Set the background color
                            textStyle: const TextStyle(
                                color: textColor), // Set the text color
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 24.0), // Set the padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Set the border radius
                            ),
                          ),
                          onPressed: () {
                            azaanBloc
                                .getLatLng(azaanBloc.formInputs)
                                .then((value) {
                              print("value $value");
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

                              azaanBloc
                                  .getTodayAzaan(azaanBloc.formInputs)
                                  .then((value) {
                                azaanBloc.setSchedularTimer();
                                azaanBloc.formInputs
                                    .saveInfo(azaanBloc.formInputs.toString());
                              });
                            });
                          },
                          child: const Text('Save Settings'),
                        ),
                      ],
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
}
