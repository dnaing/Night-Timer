import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dial_button.dart';
import 'dial_painter.dart';

class CustomDial extends StatefulWidget {
  const CustomDial({super.key});

  @override
  State<CustomDial> createState() => _CustomDialState();
}

class _CustomDialState extends State<CustomDial> {

  // Handles dial minutes logic
  int minutes = 0;
  int currentTick = 0;

  // Handles all date time logic
  DateTime curTime = DateTime.now();
  late String formattedTime;
  Timer? endEstimationTimer; 
  bool isEndEstimationTimerActive = false; 

  // Handles count down timer logic
  int minutesAtStart = 0;

  // Preset canvas sizes
  double canvasWidth = 400;
  double canvasHeight = 400;

  // Handles all dial positions and radius arguments
  double dialDotOriginX = 200;
  double dialDotOriginY = 40;
  late double dialDotCenterX;
  late double dialDotCenterY;
  double dialDotRadius = 18;
  late double dialRadius; 

  // Used only if tick marks are to be displayed on the dial
  Set<List<double>> clockIncrements = {};
  bool displayTickMarks = false;

  // Handles native android platform
  static const platform = MethodChannel('com.example.client/platform_methods');

  // Handles button active states
  bool refreshButtonActive = true;
  bool playButtonActive = true;
  bool stopButtonActive = false;

  // Handle settings
  bool? vibrationActive = true;

  // Custom Dial Constructor
  _CustomDialState() {
    dialRadius = min(canvasWidth, canvasHeight) / 2.5; // 160
    dialDotCenterX = canvasWidth / 2;
    dialDotCenterY = (canvasHeight / 2) - dialRadius;
    dialDotRadius *= 10;

    intl.DateFormat formatter = intl.DateFormat('jm');
    formattedTime = formatter.format(curTime);
  
    // adding tick marks to the dial
    double angle = 0;
    for (int i = 0; i < 60; i++) {
      List<double> curIncrement = [200 + (dialRadius * cos(angle * (pi / 180))), 200 + (dialRadius * sin(angle * (pi / 180)))];
      clockIncrements.add(curIncrement);
      angle += 6;
    }

  }

  @override
  void initState() {

    super.initState();
    appInitState();
    vibrationActive = Settings.getValue('key-vibrate');
    print('=================================');
    print(vibrationActive);

    // Listen for messages from Android
    platform.setMethodCallHandler((call) async {
      if (call.method == "updateTimeLeft") {
        final timeLeft = call.arguments["timeLeft"];
        setState(() {
          minutes = timeLeft;
          if (minutes == 0) {
            stopAction(false);
          }
        });
      } else if (call.method == "updateEndEstimation") {
        updateEndTime();
      }
    });

  }

  // Dispose method
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> appInitState() async {
    final prefs = await SharedPreferences.getInstance();
    final isTimerRunning = prefs.getBool('isTimerRunning') ?? false;

    if (isTimerRunning) {
      setState(() {
        playButtonActive = false;
        refreshButtonActive = false;
        stopButtonActive = true;
      });

    } else {
      startEndEstimationTimer();
    }
  }

  bool isWithinDialDot(Offset localPosition) {
    Offset dialDotCenterPosition = Offset(dialDotCenterX, dialDotCenterY);
    double distance = (localPosition - dialDotCenterPosition).distance;
    return playButtonActive && (distance <= dialDotRadius);
  }

  void updateDialDot(DragUpdateDetails details) {
    // Set dial to local position but only if local position is on dial circumference
    Offset dialCenter = Offset(canvasWidth / 2, canvasHeight / 2);
    Offset dialVector = details.localPosition - dialCenter; // This tells a vector (x,y) of how to reach local position from center
    double distance = dialVector.distance; // This gets the distance between center of dial and our local position
    Offset normalizedDialVector = dialVector / distance; // Dividing these two normalizes our vector so x and y are both between 0 and 1
    Offset adjustedDialVector = normalizedDialVector * dialRadius;

    setState(() {
      
      // Dial not allowed to move counterclockwise at <= 0 minutes
      if (minutes <= 0 && adjustedDialVector.dx < 0) {
        dialDotCenterX = dialDotOriginX;
        dialDotCenterY = dialDotOriginY;
      } else {
        dialDotCenterX = dialCenter.dx + adjustedDialVector.dx;
        dialDotCenterY = dialCenter.dy + adjustedDialVector.dy;
      }
      
      updateTick(dialDotCenterX, dialDotCenterY, dialCenter.dx, dialCenter.dy, adjustedDialVector);
      updateEndTime();

    });
  }

  void updateTick(double dialDotCenterX, double dialDotCenterY, double dialCenterX, double dialCenterY, Offset adjustedDialVector) {
      double angleInDegrees = (atan2(dialDotCenterY - dialCenterY, dialDotCenterX - dialCenterX)) * (180 / pi); // gets angle of dial dot in degrees
      double normalizedAngle = (angleInDegrees - 270) % 360; // normalized degrees to be in range of 0 to 360

      int newTick = normalizedAngle ~/ 6;

      if (newTick != currentTick) {

        if (vibrationActive == true) {
          HapticFeedback.vibrate();
        }
        
        if (currentTick == 59 && newTick >= 0 && adjustedDialVector.dx >= 0) { // if dial is about to rotate around and it is clockwise
          minutes += (60 - currentTick) + newTick;
        } else if (currentTick == 0 && newTick <= 59 && adjustedDialVector.dx <= 0) { // if dial is about to rotate and it is counterclockwise
          minutes -= (60 - newTick);
        } else if (newTick > currentTick) { // increment time
          minutes += newTick - currentTick;
        } else {
          minutes -= currentTick - newTick; // decrement time
        }
        currentTick = newTick;
      }
  }

  void updateEndTime() {  
    DateTime newTime = curTime.add(Duration(minutes: minutes));
    intl.DateFormat formatter = intl.DateFormat('jm');
    formattedTime = formatter.format(newTime);
  }

  void startEndEstimationTimer() {
    print("End estimation timer started");
    if (!isEndEstimationTimerActive) {
      print("End estimation timer is actually being started");
      isEndEstimationTimerActive = true;
      // Start a timer to update the end time estimation every second
      endEstimationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
 
        // Check if the current time has changed
        DateTime now = DateTime.now();
        if (now != curTime) {
          setState(() {
            curTime = now;
            updateEndTime();
          });
        }
      });

    }
  }

  void refreshAction() {

    HapticFeedback.heavyImpact();
    setState(() {
      dialDotCenterX = canvasWidth / 2;
      dialDotCenterY = (canvasHeight / 2) - dialRadius;
      currentTick = 0;
      minutes = 0;
      updateEndTime();    
    });

  }

  Future<void> saveTimerState(bool isTimerRunning) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTimerRunning', isTimerRunning);
  }

  Future<void> playAction() async {

    HapticFeedback.heavyImpact();

    if (minutes > 0) {
      // Cancel the timer that shows the estimated end time so that it is now static and unchanging
      endEstimationTimer?.cancel();

      // Start timer running in the background
      // This is the android native timer
      startBackgroundTimer();
      saveTimerState(true); // Save the timer as running
    
      // Update which buttons are active and save current minutes 
      setState(() {
        playButtonActive = false;
        minutesAtStart = minutes;
        refreshButtonActive = false;
        stopButtonActive = true;
      });
    }

  }

  void stopAction(bool invokeNativeMethod) {
    HapticFeedback.heavyImpact();

    // If flag is true, that means that this method was enabled by hitting the stop button on flutter side
    // In this case we want to invoke the stopBackgroundTimer method on the android side and reset states
    // If the flag is false, that means that the timer is already stopped and notification cancelled
    // In this case, we only want to reset our states
    if (invokeNativeMethod) {
      stopBackgroundTimer();
    }

    saveTimerState(false); // Save the timer as being stopped
    isEndEstimationTimerActive = false;
    
    // Start a timer to update the end time estimation every second
    startEndEstimationTimer();
 
    // Update minutes back to what it was before the timer started
    // Update which buttons are active
    setState(() {
      minutes = minutesAtStart;
      refreshButtonActive = true;
      playButtonActive = true;
      stopButtonActive = false;
    });
  }

  Future<void> startBackgroundTimer() async {
    try {
      await platform.invokeMethod('startBackgroundTimer', {'duration': minutes.toString()});

    } on PlatformException catch(e) {
      print('Failed to start background timer: ${e.message}.'); 
    }
  }

  Future<void> stopBackgroundTimer() async {
    try {
      await platform.invokeMethod('stopBackgroundTimer');
    } on PlatformException catch(e) {
      print('Failed to stop background timer: ${e.message}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 60,
        ),

        Visibility(
          visible: refreshButtonActive,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: DialButton(
            buttonSize: 50, 
            icon: Ionicons.refresh_circle, 
            buttonAction: refreshAction, 
            buttonActive: refreshButtonActive
          )
        ),
        
        FittedBox(
          child: SizedBox(
            child: GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                if (isWithinDialDot(details.localPosition)) {
                  updateDialDot(details);
                }   
              },
              child: DialPainterMain(minutes: minutes, dialDotCenterX: dialDotCenterX, dialDotCenterY: dialDotCenterY, clockIncrements: clockIncrements, formattedTime: formattedTime, playButtonActive: playButtonActive, canvasHeight: canvasHeight, canvasWidth: canvasWidth, displayTickMarks: displayTickMarks)
            ),
          ),
        ),
        
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                ignoring: !playButtonActive,
                child: AnimatedOpacity(
                  opacity: playButtonActive ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: DialButton(buttonSize: 75, icon: Ionicons.play_circle, buttonAction: () => playAction(), buttonActive: playButtonActive),
                ),
              ),
              IgnorePointer(
                ignoring: playButtonActive,
                child: AnimatedOpacity(
                  opacity: playButtonActive ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: DialButton(buttonSize: 75, icon: Ionicons.stop_circle, buttonAction: () => stopAction(true), buttonActive: stopButtonActive),
                ),
              ),
            ]      
          ),
        ),
      ],
    );
  }
}