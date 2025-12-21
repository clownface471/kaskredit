// lib/core/utils/firestore_helpers.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelpers {
  /// ✅ Safe map conversion for web compatibility
  static Map<String, dynamic> safeMapConversion(dynamic data) {
    if (data == null) {
      throw Exception('Document data is null');
    }

    if (data is Map<String, dynamic>) {
      return data;
    }

    // Handle LegacyJavaScriptObject on web
    try {
      return Map<String, dynamic>.from(data as Map);
    } catch (e) {
      throw Exception('Failed to convert data to Map<String, dynamic>: $e');
    }
  }

  /// ✅ Safe timestamp parsing
  static DateTime parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  /// ✅ Safe double parsing
  static double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// ✅ Safe int parsing
  static int parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// ✅ Safe string parsing
  static String parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// ✅ Safe bool parsing
  static bool parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return false;
  }
}