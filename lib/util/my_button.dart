import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
final String text;
VoidCallback onPressed;

  MyButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: Text(text),
      // add a color according to our custome theme
    );
  }
}
