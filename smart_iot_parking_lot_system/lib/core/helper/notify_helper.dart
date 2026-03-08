import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
class NotifyHelper {
  static Future<List<dynamic>> fetchHistory() async {
    final historyUrl = Uri.parse(Config.notifyUrl);
    try {
      await Future.delayed(Duration(seconds: 2));
      final response = await http.get(historyUrl);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'];
      } else {
        throw Exception("Lỗi HTTP: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi server: $e");
    }
  }

}
