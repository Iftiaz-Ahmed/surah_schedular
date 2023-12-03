import 'package:cast/device.dart';
import 'package:cast/discovery_service.dart';
import 'package:flutter/material.dart';

class CastAudio extends StatefulWidget {
  const CastAudio({Key? key}) : super(key: key);

  @override
  State<CastAudio> createState() => _CastAudioState();
}

class _CastAudioState extends State<CastAudio> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CastDevice>>(
      future: CastDiscoveryService().search(),
      builder: (context, snapshot) {
        print(snapshot.error.toString());
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error.toString()}',
            ),
          );
        } else if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.isEmpty) {
          return Column(
            children: [
              Center(
                child: Text(
                  'No Chromecast founded',
                ),
              ),
            ],
          );
        }

        return Column(
          children: snapshot.data!.map((device) {
            return ListTile(
              title: Text(device.name),
              onTap: () {
                // _connectToYourApp(context, device);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
