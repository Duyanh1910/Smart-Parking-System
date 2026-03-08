import 'package:shared_preferences/shared_preferences.dart';
class SharedPref {
  static SharedPreferences? _pref;

  static Future<SharedPreferences> _instance() async {
    _pref ??= await SharedPreferences.getInstance();
    return _pref!;
  }

  static Future<String> getUserName() async {
    final pref = await _instance();
    return pref.getString('username') ?? 'User';
  }

  static Future<bool> checkLogin() async {
    final pref = await _instance();
    final token = pref.getString('token')?.trim();
    return token != null && token.isNotEmpty;
  }

  static Future<void> destroySession() async {
    final pref = await _instance();
    await pref.remove('username');
    await pref.remove('token');
  }
}
