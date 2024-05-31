import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ionicons/ionicons.dart';
// import 'package:audioplayers/audioplayers.dart';

import 'dial_button.dart';



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
  Timer endEstimationTimer = Timer(Duration.zero, () {});

  // Handles count down timer logic
  late Timer countDownTimer;
  late Timer audioStoppingTimer;
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

  // Handles native android audiomanager platform
  static const platform = MethodChannel('com.example.client/audio');

  // Handles button active states
  bool refreshButtonActive = true;
  bool playButtonActive = true;
  bool pauseButtonActive = false;
  bool stopButtonActive = false;

  // Custom Dial Constructor
  _CustomDialState() {
    dialRadius = min(canvasWidth, canvasHeight) / 2.5; // 160
    dialDotCenterX = canvasWidth / 2;
    dialDotCenterY = (canvasHeight / 2) - dialRadius;
    dialDotRadius *= 10;

    // DateTime newTime = curTime.add(Duration(minutes: 170));
    intl.DateFormat formatter = intl.DateFormat('jm');
    formattedTime = formatter.format(curTime);
  
    // Will use this later for adding tick marks to the dial
    // Leave commented for now
    // double angle = 0;
    // for (int i = 0; i < 60; i++) {
    //   List<double> curIncrement = [200 + (dialRadius * cos(angle * (pi / 180))), 200 + (dialRadius * sin(angle * (pi / 180)))];
    //   clockIncrements.add(curIncrement);
    //   angle += 6;
    // }

  }

  bool isWithinDialDot(Offset localPosition) {
    Offset dialDotCenterPosition = Offset(dialDotCenterX, dialDotCenterY);
    double distance = (localPosition - dialDotCenterPosition).distance;
    return distance <= dialDotRadius;
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
        // print(adjustedDialVector);
        HapticFeedback.vibrate();
        if (currentTick == 59 && newTick >= 0 && adjustedDialVector.dx >= 0) { // if dial is about to rotate around and it is clockwise
          minutes += (60 - currentTick) + newTick;
        } else if (currentTick == 0 && newTick <= 59 && adjustedDialVector.dx <= 0) { // if dial is about to rotate and it is counterclockwise
          minutes -= (60 - newTick);
        } else if (newTick > currentTick) { // increment time
          minutes += newTick - currentTick;
        } else {
          minutes -= currentTick - newTick; // decrement time
        }
        // print(currentTick);
        currentTick = newTick;
      }
  }

  void updateEndTime() {
    DateTime newTime = curTime.add(Duration(minutes: minutes));
    intl.DateFormat formatter = intl.DateFormat('jm');
    formattedTime = formatter.format(newTime);
  }

  void startEndEstimationTimer() {
    if (!endEstimationTimer.isActive) {
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
    setState(() {
      dialDotCenterX = canvasWidth / 2;
      dialDotCenterY = (canvasHeight / 2) - dialRadius;
      currentTick = 0;
      minutes = 0;
      updateEndTime();    
    });

  }

  void pauseAction() {
    print("Pause button clicked");
    HapticFeedback.heavyImpact();

    // Timer counting down minutes is paused
    countDownTimer.cancel();

    // Timer keeping track of estimated end time is continued
    startEndEstimationTimer();

    // Audio stopping timer is stopped
    audioStoppingTimer.cancel();

  }

  void stopAction() {

    HapticFeedback.heavyImpact();

    // Stop minute count down timer
    countDownTimer.cancel();

    // Start a timer to update the end time estimation every second
    startEndEstimationTimer();

    // Stop the timer that stops audio
    audioStoppingTimer.cancel();
    
    // Update minutes back to what it was before the timer started
    // Update which buttons are active
    setState(() {
      minutes = minutesAtStart;
      refreshButtonActive = true;
      playButtonActive = true;
      pauseButtonActive = false;
      stopButtonActive = false;
    });

  }

  Future<void> playAction() async {
    print("Play button clicked");

    // Cancel the timer that shows the estimated end time so that it is now static and unchanging
    endEstimationTimer.cancel();

    // Start the timer that would stop audio when completed
    audioStoppingTimer = Timer(Duration(seconds: minutes), stopAudio);

    // Start the timer that counts down the minutes
    countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        minutes -= 1;
      });
    });
    
    // Update which buttons are active and save current minutes 
    setState(() {
      refreshButtonActive = false;
      playButtonActive = false;
      pauseButtonActive = true;
      stopButtonActive = true;
      minutesAtStart = minutes;
    });
    
    HapticFeedback.heavyImpact();
  }

  void stopAudio() async {

    // Stop all audio playing on android device
    try {
      await platform.invokeMethod('stopAudio');
    } on PlatformException catch (e) {
      print('Failed to stop audio: ${e.message}.');
    }
    
    stopAction();
  }



  // Whenever time passes in real life, the change is reflected in here.
  @override
  void initState() {
    super.initState();
    startEndEstimationTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DialButton(buttonSize: 50, icon: Ionicons.refresh_circle, buttonAction: refreshAction, buttonActive: refreshButtonActive),
        FittedBox(
          child: SizedBox(
            child: GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                if (isWithinDialDot(details.localPosition)) {
                  updateDialDot(details);
                }   
              },
              child: CustomPaint(
                painter: DialPainter(minutes, dialDotCenterX, dialDotCenterY, clockIncrements, formattedTime),
                size: Size(canvasWidth, canvasHeight)
              )
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
                  child: DialButton(buttonSize: 75, icon: Ionicons.play_circle, buttonAction: playAction, buttonActive: playButtonActive),
                ),
              ),
              IgnorePointer(
                ignoring: playButtonActive,
                child: AnimatedOpacity(
                  opacity: playButtonActive ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DialButton(buttonSize: 75, icon: Ionicons.pause_circle, buttonAction: pauseAction, buttonActive: pauseButtonActive),
                      DialButton(buttonSize: 75, icon: Ionicons.stop_circle, buttonAction: stopAction, buttonActive: stopButtonActive),
                    ]
                  )
                ),
              ),
            ],
          )
        )
        
        
      ],
    );
  }
}

class DialPainter extends CustomPainter {

  int minutes;
  String formattedTime;
  
  double dialDotCenterX;
  double dialDotCenterY;
  Set<List<double>> clockIncrements;
  DialPainter(this.minutes, this.dialDotCenterX, this.dialDotCenterY, this.clockIncrements, this.formattedTime);
  

  @override
    void paint(Canvas canvas, Size size) {

      final dialCenter = Offset(size.width / 2, size.height / 2); // Center of dial
      final radius = min(size.width, size.height) / 2.5; // Radius of dial

      Offset dialDotCenter = Offset(dialDotCenterX, dialDotCenterY);
      Paint myPaint;
      TextPainter textPainter;
      Offset textOffset;
      

      // Draw the dial outline
      myPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7;
      canvas.drawCircle(
        dialCenter, 
        radius, 
        myPaint
      );

      // Draw the dial controller dot
      myPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..strokeWidth = 5;
      canvas.drawCircle(
        dialDotCenter,
        18,
        myPaint
      );

      for (final increment in clockIncrements) {
        canvas.drawCircle(
          Offset(increment.elementAt(0), increment.elementAt(1)),
          5,
          myPaint
        );
      }

      // Draw dial clock time inside the dial
      textPainter = TextPainter(
        text: TextSpan(
          text: formattedTime,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textOffset = Offset(dialCenter.dx - textPainter.width / 2, size.height / 3.2 - textPainter.height / 2);
      textPainter.paint(canvas, textOffset);

      // Draw dial minute value text inside the dial
      textPainter = TextPainter(
        text: TextSpan(
          text: minutes.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textOffset = Offset(dialCenter.dx - textPainter.width / 2, dialCenter.dy - textPainter.height / 2);
      textPainter.paint(canvas, textOffset);

      // Draw 'minute' text inside the dial
      textPainter = TextPainter(
        text: const TextSpan(
          text: 'MINUTES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textOffset = Offset(dialCenter.dx - textPainter.width / 2, size.height / 1.5 - textPainter.height / 2);
      textPainter.paint(canvas, textOffset);
    }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}