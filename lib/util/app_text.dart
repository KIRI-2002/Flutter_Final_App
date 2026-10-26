import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight fontWeight;
  final Color color;
  const AppText({
    super.key,
    required this.text,
    this.color = Colors.black,
    this.fontWeight = FontWeight.w500,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: size, fontWeight: fontWeight, color: color),
    );
  }
}
