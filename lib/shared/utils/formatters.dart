import 'package:intl/intl.dart';

class Formatters {
  /// Format number to Indonesian currency (Rp)
  static String currency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format number without currency symbol
  static String number(double number) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(number);
  }

  /// Format date to Indonesian format (dd MMM yyyy)
  static String date(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  /// Format datetime to Indonesian format with time
  static String datetime(DateTime datetime) {
    final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    return formatter.format(datetime);
  }

  /// Format time only (HH:mm)
  static String time(DateTime datetime) {
    final formatter = DateFormat('HH:mm', 'id_ID');
    return formatter.format(datetime);
  }
}
