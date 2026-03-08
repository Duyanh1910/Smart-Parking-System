import 'package:flutter/material.dart';

enum ContentType { success, failure }

class SnackBarHandler {
  static void snackBarNotify(
    ScaffoldMessengerState scaffold,
    String title,
    String msg,
    ContentType type,
  ) {
    // Chọn màu và icon theo loại
    Color bgColor;
    Icon icon;

    switch (type) {
      case ContentType.success:
        bgColor = Colors.green[600]!;
        icon = const Icon(Icons.check_circle, color: Colors.white);
        break;
      case ContentType.failure:
        bgColor = Colors.red[600]!;
        icon = const Icon(Icons.error, color: Colors.white);
        break;
    }

    final snackBar = SnackBar(
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: "OK",
        onPressed: () => scaffold.hideCurrentSnackBar(),
        textColor: Colors.white,
      ),
      content: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  msg,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    scaffold
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
