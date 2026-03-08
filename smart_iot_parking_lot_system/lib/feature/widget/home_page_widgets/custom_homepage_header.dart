import 'package:flutter/material.dart';
import 'package:smart_iot_parking_lot_system/core/theme/app_palette.dart';

import 'bottom_clipper.dart';

class CustomHeader extends StatelessWidget {
  final Widget child;

  const CustomHeader({
    super.key,required this.child
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BottomClipper(),
      child: Container(
        height: 350,
        color: AppPalette.primaryColor,
        child: Stack(
          children: [
            Positioned(top: -175, right: -250, child: clipOval(400)),
            Positioned(top: 75, right: -300, child: clipOval(400)),
            child,
          ],
        ),
      ),
    );
  }
}

Widget clipOval(double size) {
  return ClipOval(
    child: Container(
      height: size,
      width: size,
      color: Colors.white.withValues(alpha: 0.1),
    ),
  );
}
