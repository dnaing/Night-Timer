import 'package:client/Pages/settings_page.dart';
import 'package:flutter/material.dart';
import '../Widgets/Dial/dial_widget.dart';
import 'package:flutter/services.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.white,
            onPressed: navigateSettingsPage
          ),
        ],
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

  void navigateSettingsPage() {
    // Navigate to the settings page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MySettingsPage(title: "Settings")),
    );
  }

}