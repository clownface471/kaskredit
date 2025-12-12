class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  // Password validation
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < minLength) {
      return 'Password minimal $minLength karakter';
    }
    
    return null;
  }

  // Phone number validation
  static String? phoneNumber(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'Nomor telepon tidak boleh kosong' : null;
    }
    
    // Remove spaces, dashes, and parentheses
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check if it contains only digits and optional + at start
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    
    if (!phoneRegex.hasMatch(cleanNumber)) {
      return 'Format nomor telepon tidak valid';
    }
    
    return null;
  }

  // Required field validation
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? "Field"} tidak boleh kosong';
    }
    return null;
  }

  // Number validation
  static String? number(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'Angka tidak boleh kosong' : null;
    }
    
    if (double.tryParse(value) == null) {
      return 'Harus berupa angka';
    }
    
    return null;
  }

  // Positive number validation
  static String? positiveNumber(String? value, {bool required = true}) {
    final numberError = number(value, required: required);
    if (numberError != null) return numberError;
    
    if (value != null && value.isNotEmpty) {
      final num = double.parse(value);
      if (num <= 0) {
        return 'Harus lebih dari 0';
      }
    }
    
    return null;
  }

  // Min/Max validation
  static String? range(
    String? value, {
    double? min,
    double? max,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) return null;
    
    final num = double.tryParse(value);
    if (num == null) return 'Harus berupa angka';
    
    if (min != null && num < min) {
      return '${fieldName ?? "Nilai"} minimal $min';
    }
    
    if (max != null && num > max) {
      return '${fieldName ?? "Nilai"} maksimal $max';
    }
    
    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    
    if (value != password) {
      return 'Password tidak cocok';
    }
    
    return null;
  }

  // Name validation (no numbers)
  static String? name(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Nama tidak boleh kosong' : null;
    }
    
    if (value.contains(RegExp(r'[0-9]'))) {
      return 'Nama tidak boleh mengandung angka';
    }
    
    return null;
  }
}