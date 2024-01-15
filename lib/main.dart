import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surah_schedular/src/provider/azaan_bloc.dart';
import 'package:surah_schedular/src/utils/color_const.dart';
import 'package:surah_schedular/src/utils/theme_helpers.dart';
import 'package:surah_schedular/src/widgets/home.dart';
import 'package:window_manager/window_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  //Open App on Startup
  if (!kIsWeb) {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    LaunchAtStartup.instance.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
    );
  }

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
