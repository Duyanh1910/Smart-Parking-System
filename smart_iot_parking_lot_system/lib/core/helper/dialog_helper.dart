import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class AppDialogs {
  static void show(
    BuildContext context, {
    required DialogType type,
    required String title,
    required String desc,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    VoidCallback? onNeutral,
    String? okText,
    String? cancelText,
    String? neutralText,
    Color? okColor,
    Color? cancelColor,
    Color? neutralColor,
    bool thirdButton = false,
  }) {
    if (thirdButton) {
      AwesomeDialog(
        context: context,
        dialogType: type,
        animType: AnimType.rightSlide,
        title: title,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 12),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: okColor ?? const Color(0xFF00CA71),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(okText ?? 'OK', style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onNeutral?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neutralColor ?? const Color(0xFF00CA71),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(neutralText ?? 'Khác', style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cancelColor ?? Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(cancelText ?? 'Hủy', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),

      ).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: type,
        animType: AnimType.rightSlide,
        title: title,
        titleTextStyle: Theme.of(context).textTheme.headlineMedium,
        descTextStyle: Theme.of(context).textTheme.bodyMedium,
        desc: desc,
        btnOkOnPress: onConfirm,
        btnCancelOnPress: onCancel,
        btnOkText: okText ?? 'OK',
        btnCancelText: cancelText ?? 'Hủy',
        btnOkColor: okColor ?? const Color(0xFF00CA71),
        btnCancelColor: cancelColor ?? Colors.red,
      ).show();
    }
  }
}
