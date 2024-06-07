import 'package:flutter/material.dart';
import 'dart:math';

class DialPainter extends CustomPainter {

  int minutes;
  String formattedTime;
  
  double dialDotCenterX;
  double dialDotCenterY;
  Set<List<double>> clockIncrements;

  bool playButtonActive;

  DialPainter(this.minutes, this.dialDotCenterX, this.dialDotCenterY, this.clockIncrements, this.formattedTime, this.playButtonActive);
  

  @override
    void paint(Canvas canvas, Size size) {

      final dialCenter = Offset(size.width / 2, size.height / 2); // Center of dial
      final radius = min(size.width, size.height) / 2.5; // Radius of dial

      Offset dialDotCenter = Offset(dialDotCenterX, dialDotCenterY);
      Paint myPaint;
      TextPainter textPainter;
      Offset textOffset;
      
      if (playButtonActive) {
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