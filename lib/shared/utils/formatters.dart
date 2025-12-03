import 'package:intl/intl.dart';

class Formatters {
  /// Format number to Indonesian currency (Rp)
  /// Gunakan ini untuk semua formatting currency!
  /// Contoh: Formatters.currency(10000) -> "Rp 10.000"
  static String currency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format number tanpa simbol currency
  static String number(double number) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(number);
  }

  /// Format date ke format Indonesia (dd MMM yyyy)
  static String date(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  /// Format datetime dengan jam
  static String datetime(DateTime datetime) {
    final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    return formatter.format(datetime);
  }

  /// Format time only (HH:mm)
  static String time(DateTime datetime) {
    final formatter = DateFormat('HH:mm', 'id_ID');
    return formatter.format(datetime);
  }

  /// Format compact untuk chart (1Jt, 500Rb, etc)
  static String compact(double amount) {
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}Jt";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}Rb";
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  /// Format percentage
  static String percentage(double value, {int decimals = 1}) {
    return "${value.toStringAsFixed(decimals)}%";
  }

  /// Parse string currency ke double
  static double parseCurrency(String text) {
    final cleaned = text
        .replaceAll('Rp', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }
}