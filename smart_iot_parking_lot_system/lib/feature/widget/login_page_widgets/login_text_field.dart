import 'package:flutter/material.dart';

class LoginTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;

  const LoginTextField({
    super.key,
    this.isPassword = false,
    required this.hintText,
    required this.controller,
  });

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginTextFieldState();
  }
}

class _LoginTextFieldState extends State<LoginTextField> {
  late bool _isObscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: (widget.isPassword == true) ? _isObscure : false,

      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.hintText,
        prefixIcon: (widget.isPassword == true)
            ? Icon(Icons.lock, color: Color(0xFF93A5CF))
            : Icon(Icons.person, color: Color(0xFF93A5CF)),
        suffixIcon: (widget.isPassword == true)
            ? IconButton(
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
          icon: Icon(
            color: Color(0xFF93A5CF),
            (_isObscure) ? Icons.visibility : Icons.visibility_off,
          ),
        )
            : null,
      ),

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Không được để trống ô này!";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  @override
  void initState() {
    super.initState();
    _isObscure = (widget.isPassword) ? true : false;
  }
}
