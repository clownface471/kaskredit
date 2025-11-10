import 'package:intl/intl.dart';

class Formatters {
  // Ini adalah formatter utama kita
  // 'id_ID' adalah kode untuk Indonesia
  static final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ', // Simbol Rupiah
    decimalDigits: 0, // Tidak pakai desimal
  );
}