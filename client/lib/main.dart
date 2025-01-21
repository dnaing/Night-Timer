import 'package:flutter/material.dart';
import 'ColorThemes/themes.dart';
import 'Pages/home_page.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

// Initialize Settings
// Future<void> initializeSettings() async {
//   await Settings.init();
// }

void main() async {
  await Settings.init();
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