import 'package:cast/device.dart';
import 'package:cast/discovery_service.dart';
import 'package:cast/session.dart';
import 'package:cast/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:surah_schedular/src/utils/color_const.dart';

class CastAudio extends StatefulWidget {
  const CastAudio({Key? key}) : super(key: key);

  @override
  State<CastAudio> createState() => _CastAudioState();
}

class _CastAudioState extends State<CastAudio> {
  Future<List<CastDevice>>? _future;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _startSearch();
    setState(() {
      _connected = CastSessionManager().sessions.isNotEmpty ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CastDevice>>(
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
          return const Column(
            children: [
              Center(
                child: Text(
                  'No Chromecast founded',
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              padding: EdgeInsets.only(left: 10),
              child: Column(
                children: snapshot.data!.map((device) {
                  return ListTile(
                    // tileColor: ,
                    title: Text(
                      device.extras['fn'].toString(),
                      style: const TextStyle(color: textColor),
                    ),
                    onTap: () {
                      // _connectToYourApp(context, device);
                      _connectAndPlayMedia(context, device);
                    },
                  );
                }).toList(),
              ),
            ),
            if (_connected)
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    if (CastSessionManager().sessions.first.state ==
                        CastSessionState.connected) {
                      CastSessionManager().endSession(
                          CastSessionManager().sessions.first.sessionId);
                    }
                  },
                  child: const Text(
                    'Disconnect',
                    style: TextStyle(color: textColor),
                  ))
          ],
        );
      },
    );
  }

  void _startSearch() {
    _future = CastDiscoveryService().search();
  }

  Future<void> _connectToYourApp(
      BuildContext context, CastDevice object) async {
    final session = await CastSessionManager().startSession(object);

    session.stateStream.listen((state) {
      if (state == CastSessionState.connected) {
        final snackBar = SnackBar(content: Text('Connected'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        _sendMessageToYourApp(session);
      }
    });

    session.messageStream.listen((message) {
      print('receive message: $message');
    });

    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'LAUNCH',
      'appId': 'Youtube', // set the appId of your app here
    });
  }

  void _sendMessageToYourApp(CastSession session) {
    print('_sendMessageToYourApp');

    session.sendMessage('urn:x-cast:namespace-of-the-app', {
      'type': 'sample',
    });
  }

  Future<void> _connectAndPlayMedia(
      BuildContext context, CastDevice object) async {
    final session = await CastSessionManager().startSession(object);
    setState(() {
      _connected = CastSessionManager().sessions.isNotEmpty ? true : false;
    });
    session.stateStream.listen((state) {
      if (state == CastSessionState.connected) {
        final snackBar = SnackBar(content: Text('Connected'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });

    var index = 0;

    session.messageStream.listen((message) {
      index += 1;

      print('receive message: $message');

      // if (index == 2) {
      //   Future.delayed(Duration(seconds: 5)).then((x) {
      //     _sendMessagePlayVideo(session);
      //   });
      // }
    });

    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'LAUNCH',
      'appId': 'CC1AD845', // set the appId of your app here
    });
  }

  void _sendMessagePlayVideo(CastSession session) {
    print('_sendMessagePlayVideo');

    var message = {
      // Here you can plug an URL to any mp4, webm, mp3 or jpg file with the proper contentType.
      'contentId': 'https://www.islamcan.com/audio/adhan/azan12.mp3',
      'contentType': 'audio/mp3',
      'streamType': 'BUFFERED', // or LIVE

      // Title and cover displayed while buffering
      'metadata': {
        'type': 0,
        'metadataType': 0,
        'title': "Adhan",
      }
    };

    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'LOAD',
      'autoPlay': true,
      'currentTime': 0,
      'media': message,
    });
  }
}
