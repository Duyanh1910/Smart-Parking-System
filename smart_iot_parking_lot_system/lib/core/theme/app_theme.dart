import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppTheme {
  static _border([Color color = AppPalette.borderColor]) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 2),
    borderRadius: BorderRadius.circular(10),
  );
  static final theme = ThemeData(
    inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.all(20),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(Color(0xFF4b68FF)),
        focusedErrorBorder: _border(AppPalette.errorColor),
        errorBorder: _border(AppPalette.errorColor),
        hintStyle: TextStyle(color: Colors.grey),
        floatingLabelBehavior: FloatingLabelBehavior.always,
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
