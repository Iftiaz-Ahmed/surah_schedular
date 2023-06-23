import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surah_schedular/src/Components/input_field.dart';
import 'package:surah_schedular/src/provider/azaan_bloc.dart';
import 'package:surah_schedular/src/screens/schedule_surah.dart';
import 'package:surah_schedular/src/utils/color_const.dart';
import 'package:surah_schedular/src/utils/theme_helpers.dart';
import 'package:surah_schedular/src/widgets/azaan_view.dart';
import 'package:surah_schedular/src/widgets/method_dropdown.dart';
import 'package:surah_schedular/src/widgets/school_dropdown.dart';
import 'package:surah_schedular/src/widgets/surah_dropdown.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<AzaanBloc>.value(value: AzaanBloc()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surah Schedular',
      theme: ThemeData(
          fontFamily: 'Trebuchet',
          appBarTheme: AppBarTheme(
              // toolbarTextStyle: const TextStyle(color: kBrandBlack),
              backgroundColor: appBg,
              iconTheme: const IconThemeData(color: iconColors),
              foregroundColor: iconColors),
          canvasColor: bgColor,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: ThemeHelpers().createMaterialColor(primarySwatch)).copyWith(background: bgColor)),
      home: const MyHomePage(title: 'Surah Schedular'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int count = 0;

  Future<void> initializeData(context) async {
    if (count == 0) {
      count++;
      AzaanBloc azaanBloc = Provider.of<AzaanBloc>(context);
      final formInput = azaanBloc.formInputs;
      formInput.city = "New York";
      formInput.country = "United States";
      await azaanBloc.getTodayAzaan(formInput.city, formInput.country, formInput.method, formInput.school).then((value) {
        azaanBloc.setSchedularTimer();
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
                textStyle: const TextStyle(color: textColor), // Set the text color
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Set the padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Set the border radius
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScheduleSurah()),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const AzaanView(),
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                azaanBloc.formInputs.country = value;
                              });
                            },
                          ),
                        ),
                        const MethodDropdown(),
                        const SchoolDropdown(),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Set the background color
                            textStyle: const TextStyle(color: textColor), // Set the text color
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Set the padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), // Set the border radius
                            ),
                          ),
                          onPressed: () {
                            azaanBloc
                                .getTodayAzaan(
                              azaanBloc.formInputs.city,
                              azaanBloc.formInputs.country,
                              azaanBloc.formInputs.method,
                              azaanBloc.formInputs.school,
                            )
                                .then((value) {
                              azaanBloc.setSchedularTimer();
                            });
                          },
                          child: const Text('Save Settings'),
                        ),
                        const SurahDropdown()
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Set the background color
                      textStyle: const TextStyle(color: textColor), // Set the text color
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Set the padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Set the border radius
                      ),
                    ),
                    onPressed: () {
                      azaanBloc.prayerSchedular.addNewSchedule("Magrib Azaan 1 2 3 4 5 6 7", "21-06-2023", "22:35", 0, "");
                    },
                    child: const Text('Play'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow, // Set the background color
                      textStyle: const TextStyle(color: textColor), // Set the text color
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Set the padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Set the border radius
                      ),
                    ),
                    onPressed: () {
                      azaanBloc.prayerSchedular.pausePlayer();
                    },
                    child: const Text('Pause'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Set the background color
                      textStyle: const TextStyle(color: textColor), // Set the text color
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Set the padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Set the border radius
                      ),
                    ),
                    onPressed: () {
                      azaanBloc.prayerSchedular.resumePlayer();
                    },
                    child: const Text('Resume'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Set the background color
                      textStyle: const TextStyle(color: textColor), // Set the text color
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Set the padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Set the border radius
                      ),
                    ),
                    onPressed: () {
                      azaanBloc.prayerSchedular.stopPlayer();
                    },
                    child: const Text('Stop'),
                  ),
                ],
              ),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
