import 'package:flutter/material.dart';
import 'dart:math';

class CustomDial extends StatefulWidget {
  const CustomDial({super.key});

  @override
  State<CustomDial> createState() => _CustomDialState();
}

class _CustomDialState extends State<CustomDial> {

  int time = 0;
  double canvasWidth = 400;
  double canvasHeight = 400;
  double dialDotCenterX = 200;
  double dialDotCenterY = 0; // Currenlty hardcoded
  double dialDotRadius = 72;
  double dialRadius = 160;

  _CustomDialState() {
    dialDotCenterX = canvasWidth / 2;
    dialDotCenterY = (canvasHeight / 2) - dialRadius;
  }

  bool isWithinDialDot(Offset localPosition) {

    Offset dialDotCenterPosition = Offset(dialDotCenterX, dialDotCenterY);
    double distance = (localPosition - dialDotCenterPosition).distance;
    return distance <= dialDotRadius;
  }

  void updateDialDot(DragUpdateDetails details) {
    setState(() {
      dialDotCenterX += details.delta.dx;
      dialDotCenterY += details.delta.dy;
    });

  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            if (isWithinDialDot(details.localPosition)) {
              updateDialDot(details);
            }   
          },
          child: CustomPaint(
            painter: DialPainter(time, dialDotCenterX, dialDotCenterY),
            size: const Size(400,400)
          )
        ),
      ),
    );
  }
}


class DialPainter extends CustomPainter {

  int time;
  double dialDotCenterX;
  double dialDotCenterY;
  DialPainter(this.time, this.dialDotCenterX, this.dialDotCenterY);

  @override
    void paint(Canvas canvas, Size size) {

      final dialCenter = Offset(size.width / 2, size.height / 2); // Center of dial
      final radius = min(size.width, size.height) / 2.5; // Radius of dial

      // Offset dialDotCenter = Offset(size.width / 2, (size.height / 2) - radius); // Center of dial dot
      Offset dialDotCenter = Offset(dialDotCenterX, dialDotCenterY);
      Paint myPaint;

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

      // Draw text inside the dial
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: time.toString(),
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
      Offset textOffset = Offset(dialCenter.dx - textPainter.width / 2, dialCenter.dy - textPainter.height / 2);
      textPainter.paint(canvas, textOffset);

    }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}