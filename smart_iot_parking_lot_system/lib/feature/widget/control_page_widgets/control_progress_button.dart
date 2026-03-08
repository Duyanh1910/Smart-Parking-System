import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class ControlProgressButton extends StatefulWidget {
  const ControlProgressButton({
    super.key,
    required this.onPressed,
    required this.icons,
    required this.idleColor,
    required this.title,
  });

  final Future<void> Function() onPressed;
  final IconData icons;
  final Color idleColor;
  final String title;

  @override
  State<ControlProgressButton> createState() => _ControlProgressButtonState();
}

class _ControlProgressButtonState extends State<ControlProgressButton> {
  ButtonState _buttonState = ButtonState.idle;

  Future<void> _handlePress() async {
    if (_buttonState == ButtonState.loading) return;

    setState(() => _buttonState = ButtonState.loading);
    try {
      await widget.onPressed();
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _buttonState = ButtonState.success);

      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() => _buttonState = ButtonState.idle);
    } catch (e) {
      setState(() => _buttonState = ButtonState.fail);

      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() => _buttonState = ButtonState.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressButton.icon(
      state: _buttonState,
      onPressed: _handlePress,

      iconedButtons: {
        ButtonState.idle: IconedButton(
          text: widget.title,
          icon: Icon(widget.icons, color: Colors.white),
          color: widget.idleColor,
        ),
        ButtonState.loading: const IconedButton(
          text: "Loading...",
          color: Colors.white,
        ),
        ButtonState.fail: IconedButton(
          text: "Thất bại",
          icon: const Icon(Icons.error, color: Colors.white),
          color: Colors.red.shade400,
        ),
        ButtonState.success: IconedButton(
          text: "Thành công!",
          icon: const Icon(Icons.check_circle, color: Colors.white),
          color: Colors.green.shade400,
        ),
      },

      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      textStyle: const TextStyle(fontSize: 22.0, color: Colors.white),
      radius: 100.0,
      maxWidth: 260.0,
      height: 60.0,
    );
  }
}
