import 'package:flutter/material.dart';
// import 'package:ionicons/ionicons.dart';
// import 'dial_painter.dart';

class DialButton extends StatefulWidget {

  final double buttonSize; // Declare buttonSize as a member variable
  final VoidCallback buttonAction;
  final IconData icon;


  const DialButton({
    super.key, 
    required this.buttonSize,
    required this.icon,
    required this.buttonAction,
    }); // Initialize buttonSize through the constructor

  @override
  State<DialButton> createState() => _DialButtonState();
}

class _DialButtonState extends State<DialButton> {


  void refreshAction() {
    print('Refresh pushed');
  }

  void playAction() {
    print('Play pushed');
  }
  


  @override
  Widget build(BuildContext context) {

    return Center(
      child: IconButton(
        color: Colors.white,
        iconSize: widget.buttonSize,
        icon: Icon(widget.icon),
        onPressed: widget.buttonAction,
      ),
    );




  }
}