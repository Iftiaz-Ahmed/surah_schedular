import 'dart:async';

import 'package:cast/device.dart';
import 'package:cast/discovery_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:surah_schedular/src/utils/color_const.dart';

import '../provider/azaan_bloc.dart';

class CastAudio extends StatefulWidget {
  const CastAudio({Key? key}) : super(key: key);

  @override
  State<CastAudio> createState() => _CastAudioState();
}

class _CastAudioState extends State<CastAudio> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<CastDevice>>? _future;
  bool searchDevice = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);
    return Container(
      key: _scaffoldKey,
      child: !searchDevice
          ? Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton(
                      onPressed: () {
                        setState(() {
                          searchDevice = true;
                        });
                        _startSearch();
                      },
                      child: const Text(
                        'Search Nearby Devices',
                        style: TextStyle(color: textColor),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  if (azaanBloc.castConnected)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const GlowIcon(
                              Icons.circle,
                              color: Colors.green,
                              size: 14,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Connected to ${azaanBloc.castDevice.name}',
                              style: const TextStyle(
                                  color: textColor, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 60,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () {
                              // if (CastSessionManager().sessions.first.state ==
                              //     CastSessionState.connected) {
                              //   CastSessionManager().endSession(
                              //       CastSessionManager()
                              //           .sessions
                              //           .first
                              //           .sessionId);
                              // }
                              azaanBloc.castConnected = false;
                              azaanBloc.saveDataLocally("cast audio");
                            },
                            child: const Text(
                              'Disconnect',
                              style: TextStyle(color: textColor),
                            ))
                      ],
                    )
                ],
              ),
            )
          : FutureBuilder<List<CastDevice>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error.toString()}',
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data!.isEmpty) {
                  Timer(const Duration(seconds: 3), () {
                    setState(() {
                      searchDevice = false;
                    });
                  });
                  return const Column(
                    children: [
                      Center(
                        child: Text(
                          'No Chromecast founded',
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: const EdgeInsets.only(left: 10),
                      height: 200,
                      child: SingleChildScrollView(
                        child: Column(
                          children: snapshot.data!.map((device) {
                            return ListTile(
                              // tileColor: ,
                              title: Text(
                                device.name.toString(),
                                style: const TextStyle(color: textColor),
                              ),
                              onTap: () {
                                azaanBloc.castDevice = device;
                                // azaanBloc
                                //     .connectToCastDevice(
                                //         _scaffoldKey.currentContext)
                                //     .then((value) {});
                                azaanBloc.castConnected = true;
                                azaanBloc.saveDataLocally("cast audio");

                                setState(() {
                                  searchDevice = false;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  void _startSearch() {
    Future.microtask(() {
      try {
        _future = CastDiscoveryService().search();
      } catch (e) {
        print(e);
      }
    });
  }
}
