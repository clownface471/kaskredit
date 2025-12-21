// lib/core/utils/validators.dart

class Validators {
  // Email Validator dengan regex yang lebih ketat
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  // Password Validator - minimal 6 karakter
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    
    // Optional: Tambahkan validasi kekuatan password
    // if (!value.contains(RegExp(r'[A-Z]'))) {
    //   return 'Password harus mengandung huruf besar';
    // }
    
    return null;
  }

  // Confirm Password Validator
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    
    if (value != originalPassword) {
      return 'Password tidak cocok';
    }
    
    return null;
  }

  // Name Validator
  static String? name(String? value, {String fieldName = 'Nama'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName minimal 2 karakter';
    }
    
    if (value.trim().length > 100) {
      return '$fieldName maksimal 100 karakter';
    }
    
    return null;
  }

  // Phone Number Validator (Indonesia format)
  static String? phoneNumber(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Nomor HP tidak boleh kosong' : null;
    }
    
    // Hapus semua karakter non-digit
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    
    // Validasi panjang (minimal 10, maksimal 13 digit)
    if (cleaned.length < 10 || cleaned.length > 13) {
      return 'Nomor HP harus 10-13 digit';
    }
    
    // Validasi awalan (08 atau 62)
    if (!cleaned.startsWith('08') && !cleaned.startsWith('62')) {
      return 'Nomor HP harus diawali 08 atau 62';
    }
    
    return null;
  }

  // Required Field Validator
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  // Number Validator
  static String? number(
    String? value, {
    String fieldName = 'Angka',
    double? min,
    double? max,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName tidak boleh kosong' : null;
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName harus berupa angka';
    }
    
    if (min != null && number < min) {
      return '$fieldName minimal $min';
    }
    
    if (max != null && number > max) {
      return '$fieldName maksimal $max';
    }
    
    return null;
  }

  // Positive Number Validator
  static String? positiveNumber(String? value, {String fieldName = 'Angka'}) {
    final result = number(value, fieldName: fieldName);
    if (result != null) return result;
    
    final num = double.parse(value!);
    if (num <= 0) {
      return '$fieldName harus lebih dari 0';
    }
    
    return null;
  }

  // Stock Validator
  static String? stock(String? value) {
    final result = number(value, fieldName: 'Stok', min: 0);
    if (result != null) return result;
    
    final num = int.tryParse(value!);
    if (num == null || num < 0) {
      return 'Stok tidak boleh negatif';
    }
    
    return null;
  }

  // Price Validator
  static String? price(String? value, {String fieldName = 'Harga'}) {
    return positiveNumber(value, fieldName: fieldName);
  }

  // Percentage Validator
  static String? percentage(String? value) {
    final result = number(value, fieldName: 'Persentase', min: 0, max: 100);
    return result;
  }

  // Credit Down Payment Validator
  static String? downPayment(String? value, double totalAmount) {
    final result = number(value, fieldName: 'Down Payment', min: 0);
    if (result != null) return result;
    
    final dp = double.parse(value!);
    if (dp > totalAmount) {
      return 'DP tidak boleh melebihi total belanja';
    }
    
    return null;
  }

  // Tenor Validator
  static String? tenor(String? value) {
    final result = number(value, fieldName: 'Tenor', min: 1, max: 60);
    if (result != null) return result;
    
    final months = int.tryParse(value!);
    if (months == null || months < 1) {
      return 'Tenor minimal 1 bulan';
    }
    
    if (months > 60) {
      return 'Tenor maksimal 60 bulan (5 tahun)';
    }
    
    return null;
  }

  // Text Length Validator
  static String? maxLength(
    String? value,
    int maxLength, {
    String fieldName = 'Field',
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName tidak boleh kosong' : null;
    }
    
    if (value.length > maxLength) {
      return '$fieldName maksimal $maxLength karakter';
    }
    
    return null;
  }

  // Shop Name Validator
  static String? shopName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama toko tidak boleh kosong';
    }
    
    if (value.trim().length < 3) {
      return 'Nama toko minimal 3 karakter';
    }
    
    if (value.trim().length > 50) {
      return 'Nama toko maksimal 50 karakter';
    }
    
    return null;
  }

  // Composite Validator - menggabungkan beberapa validator
  static String? composite(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }
}

// Extension untuk mudahkan penggunaan
extension ValidatorExtension on String? {
  String? validate(String? Function(String?) validator) {
    return validator(this);
  }
  
  String? validateWith(List<String? Function(String?)> validators) {
    return Validators.composite(this, validators);
  }
}