import 'package:intl/intl.dart';

class FormatPrice {
  static String format(double price) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return '${formatter.format(price.toInt())} đ';
  }
  static String formatDate(String dateString) {
    DateTime dateTime;
    try {
      dateTime = DateTime.parse(dateString);
    } catch (e) {
      return dateString;
    }
    final formatter = DateFormat('d MMMM, y', 'vi_VN');
    return formatter.format(dateTime);
  }
  static String formatDateTime(String dateString) {
    DateTime dateTime;
    try {
      dateTime = DateTime.parse(dateString);
    } catch (e) {
      return dateString;
    }
    final formatter = DateFormat('HH:mm, d MMMM, y', 'vi_VN');
    return formatter.format(dateTime);
  }
}
