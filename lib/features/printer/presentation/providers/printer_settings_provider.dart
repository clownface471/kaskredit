import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'printer_settings_provider.g.dart';

class PrinterSettings {
  final String? printerIp;
  final bool autoPrint;
  final String? footerNote;

  PrinterSettings({
    this.printerIp,
    this.autoPrint = false,
    this.footerNote,
  });

  PrinterSettings copyWith({
    String? printerIp,
    bool? autoPrint,
    String? footerNote,
  }) {
    return PrinterSettings(
      printerIp: printerIp ?? this.printerIp,
      autoPrint: autoPrint ?? this.autoPrint,
      footerNote: footerNote ?? this.footerNote,
    );
  }
}

@Riverpod(keepAlive: true)
class PrinterSettingsNotifier extends _$PrinterSettingsNotifier {
  @override
  Future<PrinterSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    
    return PrinterSettings(
      printerIp: prefs.getString('printer_ip'),
      autoPrint: prefs.getBool('auto_print') ?? false,
      footerNote: prefs.getString('footer_note') ?? 'Barang yang sudah dibeli tidak dapat dikembalikan',
    );
  }

  Future<void> setPrinterIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('printer_ip', ip);
    
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(printerIp: ip));
  }

  Future<void> setAutoPrint(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_print', enabled);
    
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(autoPrint: enabled));
  }

  Future<void> setFooterNote(String note) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('footer_note', note);
    
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(footerNote: note));
  }

  Future<void> clearPrinterIp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('printer_ip');
    
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(printerIp: null));
  }
}