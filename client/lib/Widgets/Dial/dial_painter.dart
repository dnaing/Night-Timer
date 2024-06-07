import 'package:flutter/material.dart';
import 'dart:math';


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
          painter: DialPainter(widget.minutes, widget.dialDotCenterX, widget.dialDotCenterY, widget.clockIncrements, widget.formattedTime, widget.playButtonActive, _colorAnimation),
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

  DialPainter(
    this.minutes, 
    this.dialDotCenterX, 
    this.dialDotCenterY, 
    this.clockIncrements, 
    this.formattedTime, 
    this.playButtonActive,
    this.colorAnimation,
  );
  

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
          style: TextStyle(
            color: playButtonActive ? Colors.white : colorAnimation.value,
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
        text: TextSpan(
          text: 'MINUTES',
          style: TextStyle(
            color: playButtonActive ? Colors.white : colorAnimation.value,
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