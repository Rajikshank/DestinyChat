import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final Function() press;
  final IconData icon;

  PrimaryButton({
    required this.icon,
    required this.press,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ElevatedButton.icon(
      onPressed: press,
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          minimumSize: Size(0.88 * width, 48),
          primary: Color(0xFF141742),
          onPrimary: Theme.of(context).colorScheme.primary,
          textStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600)),
      icon: Icon(icon),
      label: Text(text),
    );
  }
}
