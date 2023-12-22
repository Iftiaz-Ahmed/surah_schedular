// import 'package:args/args.dart';
// import 'package:dart_chromecast/casting/cast_media.dart';
import 'package:flutter/material.dart';
// import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:surah_schedular/src/provider/azaan_bloc.dart';
import 'package:surah_schedular/src/utils/color_const.dart';
import 'package:surah_schedular/src/utils/theme_helpers.dart';
import 'package:surah_schedular/src/widgets/home.dart';
import 'package:window_manager/window_manager.dart';

// final Logger log = new Logger('Chromecast CLI');

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(1300, 740),
    size: Size(1300, 740),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<AzaanBloc>.value(value: AzaanBloc()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({key});

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
          colorScheme: ColorScheme.fromSwatch(
                  primarySwatch:
                      ThemeHelpers().createMaterialColor(primarySwatch))
              .copyWith(background: bgColor)),
      home: const MyHomePage(title: 'Digital Azaan'),
    );
  }
}
