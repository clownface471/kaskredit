// lib/core/utils/getx_utils.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Utility class untuk GetX operations
/// Centralized untuk konsistensi UI/UX
class GetXUtils {
  GetXUtils._(); // Private constructor untuk prevent instantiation

  // === SNACKBAR UTILITIES ===

  /// Show success snackbar
  static void showSuccess(
    String message, {
    String title = 'Berhasil',
    Duration duration = const Duration(seconds: 2),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
      borderColor: Colors.green.withOpacity(0.3),
      borderWidth: 1,
      icon: const Icon(Icons.check_circle, color: Colors.green),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show error snackbar
  static void showError(
    String message, {
    String title = 'Error',
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.1),
      borderColor: Colors.red.withOpacity(0.3),
      borderWidth: 1,
      icon: const Icon(Icons.error, color: Colors.red),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show warning snackbar
  static void showWarning(
    String message, {
    String title = 'Perhatian',
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withOpacity(0.1),
      borderColor: Colors.orange.withOpacity(0.3),
      borderWidth: 1,
      icon: const Icon(Icons.warning, color: Colors.orange),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show info snackbar
  static void showInfo(
    String message, {
    String title = 'Info',
    Duration duration = const Duration(seconds: 2),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.1),
      borderColor: Colors.blue.withOpacity(0.3),
      borderWidth: 1,
      icon: const Icon(Icons.info, color: Colors.blue),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  // === DIALOG UTILITIES ===

  /// Show loading dialog
  static void showLoading({String? message}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent back button
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide loading dialog
  static void hideLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Tidak',
    Color? confirmColor,
    bool isDangerous = false,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ??
                  (isDangerous ? Colors.red : Get.theme.colorScheme.primary),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show input dialog
  static Future<String?> showInputDialog({
    required String title,
    String? hint,
    String? initialValue,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    final result = await Get.dialog<String>(
      AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Get.back(result: controller.text);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  /// Show bottom sheet
  static Future<T?> showBottomSheet<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) async {
    return await Get.bottomSheet<T>(
      Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: child,
      ),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
    );
  }

  /// Show custom dialog
  static Future<T?> showCustomDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) async {
    return await Get.dialog<T>(
      child,
      barrierDismissible: barrierDismissible,
    );
  }

  // === NAVIGATION UTILITIES ===

  /// Navigate with error handling
  static Future<T?>? navigateTo<T>(
    String routeName, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    try {
      return Get.toNamed<T>(
        routeName,
        arguments: arguments,
        parameters: parameters,
      );
    } catch (e) {
      showError('Gagal navigasi: $e');
      return null;
    }
  }

  /// Navigate and remove until
  static Future<T?>? navigateOffAll<T>(
    String routeName, {
    dynamic arguments,
  }) {
    try {
      return Get.offAllNamed<T>(routeName, arguments: arguments);
    } catch (e) {
      showError('Gagal navigasi: $e');
      return null;
    }
  }

  /// Back with result
  static void goBack<T>({T? result}) {
    Get.back<T>(result: result);
  }

  /// Close all dialogs and bottom sheets
  static void closeAllOverlays() {
    while (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  // === VALIDATION UTILITIES ===

  /// Validate form and show error if invalid
  static bool validateForm(
    GlobalKey<FormState> formKey, {
    String? errorMessage,
  }) {
    if (formKey.currentState?.validate() ?? false) {
      return true;
    }

    if (errorMessage != null) {
      showError(errorMessage);
    }

    return false;
  }

  // === CONNECTIVITY UTILITIES ===

  /// Show no internet connection dialog
  static void showNoInternetDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Tidak Ada Koneksi'),
          ],
        ),
        content: const Text(
          'Tidak dapat terhubung ke internet. '
          'Periksa koneksi Anda dan coba lagi.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // === ERROR HANDLING UTILITIES ===

  /// Handle Firebase errors with user-friendly messages
  static String getFirebaseErrorMessage(dynamic error) {
    if (error == null) return 'Terjadi kesalahan';

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network')) {
      return 'Koneksi internet bermasalah';
    } else if (errorString.contains('permission')) {
      return 'Akses ditolak. Periksa izin akun Anda';
    } else if (errorString.contains('not-found')) {
      return 'Data tidak ditemukan';
    } else if (errorString.contains('already-exists')) {
      return 'Data sudah ada';
    } else if (errorString.contains('timeout')) {
      return 'Koneksi timeout. Coba lagi';
    } else if (errorString.contains('unavailable')) {
      return 'Server tidak tersedia. Coba lagi nanti';
    }

    return 'Terjadi kesalahan: $error';
  }

  /// Show Firebase error
  static void showFirebaseError(dynamic error) {
    showError(getFirebaseErrorMessage(error));
  }

  // === CONVENIENCE METHODS ===

  /// Execute async operation with loading
  static Future<T?> executeWithLoading<T>(
    Future<T> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    Function(T)? onSuccess,
    Function(dynamic)? onError,
  }) async {
    try {
      showLoading(message: loadingMessage);
      final result = await operation();
      hideLoading();

      if (successMessage != null) {
        showSuccess(successMessage);
      }

      onSuccess?.call(result);
      return result;
    } catch (e) {
      hideLoading();

      if (errorMessage != null) {
        showError(errorMessage);
      } else {
        showFirebaseError(e);
      }

      onError?.call(e);
      return null;
    }
  }

  /// Execute operation with confirmation
  static Future<T?> executeWithConfirmation<T>({
    required String title,
    required String message,
    required Future<T> Function() operation,
    String? successMessage,
    String? errorMessage,
  }) async {
    final confirmed = await showConfirmDialog(
      title: title,
      message: message,
    );

    if (!confirmed) return null;

    return await executeWithLoading<T>(
      operation,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}