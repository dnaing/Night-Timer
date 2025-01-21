import 'package:flutter/material.dart';

class DialButton extends StatefulWidget {

  final double buttonSize; // Declare buttonSize as a member variable
  final VoidCallback buttonAction;
  final IconData icon;
  final bool buttonActive;


  const DialButton({
    super.key, 
    required this.buttonSize,
    required this.icon,
    required this.buttonAction,
    required this.buttonActive,
    }); // Initialize buttonSize through the constructor

  @override
  State<DialButton> createState() => _DialButtonState();
}

class _DialButtonState extends State<DialButton> {

  @override
  Widget build(BuildContext context) {

    return Center(
      child: IconButton(
        color: Colors.white,
        iconSize: widget.buttonSize,
        icon: Icon(widget.icon),
        onPressed: widget.buttonActive ? widget.buttonAction : null,
      ),
    );

  }
}