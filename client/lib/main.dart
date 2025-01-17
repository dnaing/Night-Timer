import 'package:flutter/material.dart';
import 'ColorThemes/themes.dart';
import 'Pages/home_page.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';



// Initialize Settings
void initializeSettings() async {
  await Settings.init();
  if (Settings.containsKey('key-time-ticks') == false) {
    Settings.setValue<bool>('key-time-ticks', false);
  }
  if (Settings.containsKey('key-time-steps') == false) {
    Settings.setValue<double>('key-time-steps', 5.0);
  }
  if (Settings.containsKey('key-vibrate') == false) {
    Settings.setValue<bool>('key-vibrate', true);
  }
  // print(Settings.getValue('key-time-ticks'));
  // if (Settings.containsKey('key-fade-audio') == false) {
  //   Settings.setValue<int>('key-fade-audio', 30);
  // }
}


void main() async {
  initializeSettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Night Timer',
      theme: MyAppThemes.darkTheme,
      home: const MyHomePage(title: 'Night Timer'),
    );
  }



}