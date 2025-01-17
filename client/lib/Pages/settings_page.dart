import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';


class MySettingsPage extends StatefulWidget {
  const MySettingsPage({super.key, required this.title});

  final String title;

  @override
  State<MySettingsPage> createState() => _MySettingsPageState();
}



class _MySettingsPageState extends State<MySettingsPage> {

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
            children: <Widget>[
            const SettingsGroup(
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
              title: 'Night Timer',
              children: [
                SwitchSettingsTile(
                  settingKey: 'key-time-ticks',
                  leading: Icon(Icons.align_vertical_bottom, color: Colors.white),
                  title: 'Enable Dial Time Ticks',
                  activeColor: Colors.white,
                )
              ]
            ),
            SettingsGroup(
              titleTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
              title: 'Notifications',
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.grey,
                  trackShape: const RectangularSliderTrackShape(),
                  trackHeight: 4.0,
                  thumbColor: const Color.fromARGB(255, 255, 255, 255),
                  overlayColor: Colors.grey,
                  ),
                  child: SliderSettingsTile(
                    title: 'Adjust Dial Time Modification',
                    settingKey: 'key-slider-volume',
                    defaultValue: 5,
                    min: 0,
                    max: 60,
                    step: 1,
                    leading: const Icon(Icons.more_time, color: Colors.white),
                    onChange: (value) {
                      // Set the state of the dial modification time
                      // debugPrint('key-slider-volume: $value');
                    },
                    
                  ),
                )
              ]
            ),
            const SettingsGroup(
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
              title: 'Haptic Feedback',
              children: [
                SwitchSettingsTile(
                  settingKey: 'key-vibrate',
                  leading: Icon(Icons.vibration, color: Colors.white),
                  title: 'Enable Dial Vibrations',
                  activeColor: Colors.white,          
                ),
              ]
            ),
          ],
        )
        
      ),
    );
  }
}