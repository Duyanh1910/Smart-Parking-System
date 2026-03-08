
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'snackbar_handler.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../config/config.dart';

class LoginHelper{
  static Future<void> loginHandle(
      BuildContext context,
      String username,
      String password,
      GlobalKey<FormState> formKey,
      Function(bool) setLoading
      ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    final router = GoRouter.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    FocusScope.of(context).unfocus();
    setLoading(true);
    try{
      final response = await http.post(
        Uri.parse(Config.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', data['username'] ?? '');
        await prefs.setString('token', data['token'] ?? '');
        if (!context.mounted) return;
        router.push('/home');
      }
      else{
        final msg = data['message'] ?? 'Đăng nhập thất bại';
        SnackBarHandler.snackBarNotify(scaffoldMessenger,"Lỗi!!!",msg,ContentType.failure);
      }
    }
    catch(e){
      SnackBarHandler.snackBarNotify(scaffoldMessenger,"Lỗi!!!", "Lỗi server: $e",ContentType.failure);
    }
    finally{
      setLoading(false);
    }
  }
}