import 'package:intl/intl.dart';

class Formatters {
  // Ini adalah formatter utama kita
  // 'id_ID' adalah kode untuk Indonesia
  static final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format number ke currency string
  /// Gunakan ini untuk semua formatting currency!
  /// Contoh: Formatters.formatCurrency(10000) -> "Rp 10.000"
  static String formatCurrency(double amount) {
    return currency.format(amount);
  }

  /// Format number tanpa simbol currency
  static String formatNumber(double number) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(number);
  }

  /// Format date ke format Indonesia (dd MMM yyyy)
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  /// Format datetime dengan jam
  static String formatDateTime(DateTime datetime) {
    final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    return formatter.format(datetime);
  }

  /// Format time only (HH:mm)
  static String formatTime(DateTime datetime) {
    final formatter = DateFormat('HH:mm', 'id_ID');
    return formatter.format(datetime);
  }

  /// Format compact untuk chart (1Jt, 500Rb, etc)
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}Jt";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}Rb";
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  /// Format percentage
  static String formatPercentage(double value, {int decimals = 1}) {
    return "${value.toStringAsFixed(decimals)}%";
  }

  /// Parse string currency ke double
  static double parseCurrency(String text) {
    // Remove Rp, spaces, dots, and other non-numeric chars except comma
    final cleaned = text
        .replaceAll('Rp', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }
}