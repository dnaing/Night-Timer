import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/widgets.dart';

class DialPainter extends CustomPainter {

  @override
    void paint(Canvas canvas, Size size) {

      final center = Offset(size.width / 2, size.height / 2);
      final radius = min(size.width, size.height) / 2;
      Paint myPaint;

      // Draw the dial outline
      myPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5;
      canvas.drawCircle(
        center, 
        radius, 
        myPaint
      );

      // Draw the dial controller dot
      myPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..strokeWidth = 5;
      canvas.drawCircle(
        Offset(size.width / 2, 0),
        18,
        myPaint
      );

      // Draw text inside the dial
      TextPainter textPainter = TextPainter(
        text: const TextSpan(
          text: '45',
          style: TextStyle(
            color: Colors.white,
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      Offset textOffset = Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2);
      textPainter.paint(canvas, textOffset);

    }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}