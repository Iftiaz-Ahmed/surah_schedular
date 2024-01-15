import 'package:flutter/material.dart';
import '../utils/color_const.dart';
import '../provider/azaan_bloc.dart';
import 'package:provider/provider.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  int count = 0;
  String installationDirectory = "";

  initialize(AzaanBloc azaanBloc) async{
    if (count == 0) {
      count++;
      installationDirectory = azaanBloc.getInstallationDirectory();
      await azaanBloc.logs.readLogFile(installationDirectory);
    }
  }

  @override
  Widget build(BuildContext context) {
    AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);
    initialize(azaanBloc);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .primary,
          title: const Text(
            "Logs",
            style: TextStyle(color: textColor),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: azaanBloc.logs.logs.isNotEmpty?
          ListView.builder(
            itemCount: azaanBloc.logs.logs.length,
            itemBuilder: (BuildContext context, int index) {
              int reversedIndex = azaanBloc.logs.logs.length - 1 - index;
              String key = azaanBloc.logs.logs.keys.elementAt(reversedIndex);
              dynamic values = azaanBloc.logs.logs[key];

              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                        key,
                        style: const TextStyle(
                            color: textColor,
                            fontSize: 18
                        )
                    ),
                    const SizedBox(height: 10),
                    for (var value in values.reversed)
                      Column(
                        children: [
                          Text(value, style: TextStyle(
                              color: value.contains('Error')? Colors.red.withOpacity(1) : textColor.withOpacity(0.5),
                              fontWeight: value.contains('Error')? FontWeight.w500 : FontWeight.w400,
                              fontSize: 14,
                              letterSpacing: 3
                          )),
                          const SizedBox(height: 5)
                        ]
                      )

                  ]
              );
            },
          ):Center(
            child: Text('No log records', style: TextStyle(
                color: Colors.red.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 2
            )),
          )
        )
    );
  }
}
