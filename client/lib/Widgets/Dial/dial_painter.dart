import 'package:flutter/material.dart';
import 'dart:math';

// import 'dart:async';


class DialPainterMain extends StatefulWidget {
  final int minutes;
  final double dialDotCenterX;
  final double dialDotCenterY;
  final Set<List<double>> clockIncrements;
  final String formattedTime;
  final bool playButtonActive;
  final double canvasWidth;
  final double canvasHeight;

  const DialPainterMain({
    super.key,
    required this.minutes,
    required this.dialDotCenterX,
    required this.dialDotCenterY,
    required this.clockIncrements,
    required this.formattedTime,
    required this.playButtonActive,
    required this.canvasWidth,
    required this.canvasHeight,
  });
  
  @override
  State<DialPainterMain> createState() => _DialPainterMainState();
}

class _DialPainterMainState extends State<DialPainterMain> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  List<double> paintedAngles = []; // Store angles that are painted

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = (ColorTween(
      begin: Colors.white,
      end: Colors.blue,
    ).animate(_controller));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: DialPainter(widget.minutes, widget.dialDotCenterX, widget.dialDotCenterY, widget.clockIncrements, widget.formattedTime, widget.playButtonActive, _colorAnimation, paintedAngles),
          size: Size(widget.canvasWidth, widget.canvasHeight),
        );
      }
    );
  }
}

class DialPainter extends CustomPainter {

  int minutes;
  String formattedTime;
  
  double dialDotCenterX;
  double dialDotCenterY;
  Set<List<double>> clockIncrements;

  bool playButtonActive;

  Animation<Color?> colorAnimation;

  List<double> paintedAngles;

  

  DialPainter(
    this.minutes, 
    this.dialDotCenterX, 
    this.dialDotCenterY, 
    this.clockIncrements, 
    this.formattedTime, 
    this.playButtonActive,
    this.colorAnimation,
    this.paintedAngles
  );

  List<double> getIntermediateAnglesInRadians(double currentAngleInRadians, double lastAngleInRadians) {

    List<double> intermediateAngles = [];
    
    if (currentAngleInRadians > lastAngleInRadians) {
      for (double angle = lastAngleInRadians; angle < currentAngleInRadians; angle += 0.05) {
        intermediateAngles.add(angle % (2*pi));
      }
    }
    return intermediateAngles;
  }
  

  @override
    void paint(Canvas canvas, Size size) {

      final dialCenter = Offset(size.width / 2, size.height / 2); // Center of dial
      final radius = min(size.width, size.height) / 2.5; // Radius of dial
      
      const double dialDotRadius = 18;

      Offset dialDotCenter = Offset(dialDotCenterX, dialDotCenterY);
      Paint myPaint;
      TextPainter textPainter;
      Offset textOffset;
  
      if (playButtonActive) {

        // Draws the grey dial base outline
        myPaint = Paint()
          ..color = const Color.fromARGB(255, 60, 60, 60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7;
        canvas.drawCircle(
          dialCenter, 
          radius, 
          myPaint
        );

        // Define white paint for the painted regions
        myPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7;
        
        // Draw the painted regions with white paint
        for (double angle in paintedAngles) {
          double adjustedAngle = (angle - pi / 2) % (2 * pi);
          canvas.drawArc(
            Rect.fromCircle(center : dialCenter, radius : radius),
            adjustedAngle,
            0.1,
            false,
            myPaint
          );
        }

        // Add current paintedAngle to our list of paintedAngles
        double currentAngleInRadians = (atan2(dialDotCenterY - dialCenter.dy, dialDotCenterX - dialCenter.dx) + 2 * pi) % (2 * pi); // gets angle of dial dot in radians
        currentAngleInRadians = (currentAngleInRadians + pi / 2) % (2 * pi);
        // print(currentAngleInRadians);

        if (!paintedAngles.contains(currentAngleInRadians)) {
          paintedAngles.add(currentAngleInRadians);
        }

        double lastAngleInRadians = paintedAngles.last;
        if (currentAngleInRadians != lastAngleInRadians) {
          paintedAngles.addAll(getIntermediateAnglesInRadians(currentAngleInRadians, lastAngleInRadians));
        }
        

        // Draw the dial controller dot
        myPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill
          ..strokeWidth = 5;
        canvas.drawCircle(
          dialDotCenter,
          dialDotRadius,
          myPaint
        );

        
        

        // Add tick marks to the dial
        for (final increment in clockIncrements) {
          canvas.drawCircle(
            Offset(increment.elementAt(0), increment.elementAt(1)),
            5,
            myPaint
          );
        }
      }


      // Draw dial clock time inside the dial
      textPainter = TextPainter(
        text: TextSpan(
          text: formattedTime,
          style: TextStyle(
            color: playButtonActive ? Colors.white : colorAnimation.value,
            fontSize: 45,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tempter',
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textOffset = Offset(dialCenter.dx - textPainter.width / 2, size.height / 3.2 - textPainter.height / 2 - 15.0);
      textPainter.paint(canvas, textOffset);

      // Draw dial minute value text inside the dial
      textPainter = TextPainter(
        text: TextSpan(
          text: minutes.toString(),
          style: TextStyle(
            color: playButtonActive ? Colors.white : colorAnimation.value,
            fontSize: 160,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tempter',
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textOffset = Offset(dialCenter.dx - textPainter.width / 2, dialCenter.dy - textPainter.height / 2 + 3.0);
      textPainter.paint(canvas, textOffset);

      // Draw 'minutes' text inside the dial
      textPainter = TextPainter(
        text: TextSpan(
          text: 'MINUTES',
          style: TextStyle(
            color: playButtonActive ? Colors.white : colorAnimation.value,
            fontSize: 45,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tempter',
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textOffset = Offset(dialCenter.dx - textPainter.width / 2, size.height / 1.5 - textPainter.height / 2  + 28.0);
      textPainter.paint(canvas, textOffset);
    }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}