import 'package:flutter/material.dart';
import 'ColorThemes/themes.dart';
import 'Widgets/dial_painter.dart';

void main() {
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          // Set child element of container to add things
          child: const Center(
            child: CustomDial()
          ),
        ),
      ),
    );
  }
}