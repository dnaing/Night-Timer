import 'package:flutter/material.dart';

class MyAppThemes {

  static final darkTheme = ThemeData(
    primaryColor: Colors.black,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
    canvasColor: const Color.fromARGB(255, 0, 0, 0),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white), // For titles
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white; // Thumb color when the switch is on
        }
        return Colors.white; // Thumb color when the switch is off
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color.fromARGB(255, 30, 135, 220); // Track color when the switch is on
        }
        return const Color.fromARGB(255, 40, 40, 40); // Track color when the switch is off
      }),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Colors.white,
      inactiveTrackColor: Colors.grey,
      trackShape: RectangularSliderTrackShape(),
      trackHeight: 4.0,
      thumbColor: Color.fromARGB(255, 255, 255, 255),
      overlayColor: Colors.grey,

    )
  );

  static final lightTheme = ThemeData(
    primaryColor: Colors.white,
    brightness: Brightness.light,
  );

}