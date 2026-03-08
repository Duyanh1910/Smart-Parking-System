import 'package:intl/intl.dart';
class TimeFormatter{
  static String formatDate(String time) {
    final formatTime = DateTime.parse(time).toLocal();
    return DateFormat('dd/MM/yyyy HH:mm').format(formatTime);
  }
}