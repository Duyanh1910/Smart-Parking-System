import 'package:flutter/material.dart';

class AppPalette {
  static final LinearGradient gradient = LinearGradient(
    colors: [Color(0xFF4b68FF),Color(0xFFE0ECFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color borderColor = Color.fromRGBO(52, 51, 67, 1);
  static const Color errorColor = Colors.redAccent;
  static const Color transparentColor = Colors.transparent;
  static const Color primaryColor = Color(0xFF4b68FF);
}
