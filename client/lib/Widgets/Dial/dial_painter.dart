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
  final bool displayTickMarks;

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
    required this.displayTickMarks,
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
          painter: DialPainter(widget.minutes, widget.dialDotCenterX, widget.dialDotCenterY, widget.clockIncrements, widget.formattedTime, widget.playButtonActive, _colorAnimation, paintedAngles, widget.displayTickMarks),
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
  bool displayTickMarks;

  DialPainter(
    this.minutes, 
    this.dialDotCenterX, 
    this.dialDotCenterY, 
    this.clockIncrements, 
    this.formattedTime, 
    this.playButtonActive,
    this.colorAnimation,
    this.paintedAngles,
    this.displayTickMarks
  );

  @override
    void paint(Canvas canvas, Size size) {

      final dialCenter = Offset(size.width / 2, size.height / 2); // Center of dial
      final radius = min(size.width, size.height) / 2.5; // Radius of dial
      const double dialDotRadius = 18;
      Offset dialDotCenter = Offset(dialDotCenterX, dialDotCenterY);
      if (playButtonActive) {
        drawTimeTicks(canvas, dialCenter);
        drawDial(canvas, dialCenter, radius);
        drawDialDot(canvas, dialDotCenter, dialDotRadius);    
      }
      drawDialInformation(canvas, dialCenter, size);
    }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void drawTimeTicks(Canvas canvas, Offset dialCenter ) {

    if (displayTickMarks) {

      Paint myPaint;
      // Add tick marks to the dial
      var counter = 0;
      for (final increment in clockIncrements) {
        final tickStart = Offset(increment.elementAt(0), increment.elementAt(1)); // Start point of the tick mark
      
        double lineLength = 0.08; // Adjust this for the length of the tick marks
        double dx = (increment.elementAt(0) - dialCenter.dx) * lineLength;
        double dy = (increment.elementAt(1) - dialCenter.dy) * lineLength;
        final tickEnd = Offset(tickStart.dx + dx, tickStart.dy + dy);

        if (counter % 5 == 0) {
          myPaint = Paint()
            ..color = const Color.fromARGB(255, 0, 170, 255)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4;
        } else {
          myPaint = Paint()
            ..color = const Color.fromARGB(255, 255, 255, 255)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
        }

        canvas.drawLine(
          tickStart,
          tickEnd,
          myPaint,
        );

        counter += 1;

      }
    }
  }

  void drawDial(Canvas canvas, Offset dialCenter, double radius) {
    
    Paint myPaint;
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

    // Calculate the current angle of the dial dot
    double currentAngleInRadians = (atan2(dialDotCenterY - dialCenter.dy, dialDotCenterX - dialCenter.dx) + 2 * pi) % (2 * pi);
    currentAngleInRadians = (currentAngleInRadians + pi / 2) % (2 * pi); // Normalize to start at top

    // Define the gradient
    final gradient = SweepGradient(
      startAngle: 0, // Base start angle
      endAngle: 2*pi, // Base end angle
      colors: const [Color.fromARGB(255, 0, 105, 175), Color.fromARGB(255, 255, 255, 255)],
      stops: const [0, 1.0], // Control the split between white and blue
      transform: GradientRotation((minutes * (pi / 30)) - 1.5), // Rotate gradient based on dial dot
    );

    // Define white paint for the painted regions
    myPaint = Paint()
      // ..color = Colors.white
      ..shader = gradient.createShader(Rect.fromCircle(center: dialCenter, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    
    if (minutes >= 60) {
      canvas.drawCircle(
        dialCenter, 
        radius, 
        myPaint
      );
    } 
    else {
      double paintedAngle = minutes * (pi / 30);
      canvas.drawArc(
        Rect.fromCircle(center: dialCenter, radius: radius),
        -pi/2,
        paintedAngle,
        false,
        myPaint
      );

    }

  }

  void drawDialDot(Canvas canvas, Offset dialDotCenter, double dialDotRadius) {
    Paint myPaint;
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
  }

  void drawDialInformation(Canvas canvas, Offset dialCenter, Size size) {

    TextPainter textPainter;
    Offset textOffset;

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

}