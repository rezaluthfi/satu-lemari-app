class Validators {
  /// Memvalidasi format email.
  /// Mengembalikan pesan error jika tidak valid, atau null jika valid.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    // Regex ini kuat dan menerima format seperti 'user8@example.com'
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Memvalidasi kekuatan password.
  /// Mengembalikan pesan error jika tidak valid, atau null jika valid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    // Menggunakan aturan minimal 8 karakter agar konsisten dengan solusi sebelumnya.
    if (value.length < 8) {
      return 'Password minimal harus 6 karakter';
    }
    return null;
  }

  /// Memvalidasi konfirmasi password.
  /// Mengembalikan pesan error jika tidak cocok, atau null jika cocok.
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != password) {
      return 'Password tidak cocok';
    }
    return null;
  }

  /// Memvalidasi nama (misal: username).
  /// Mengembalikan pesan error jika tidak valid, atau null jika valid.
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Username minimal harus 3 karakter';
    }
    return null;
  }

  /// Memvalidasi format nomor telepon.
  /// Mengembalikan pesan error jika tidak valid, atau null jika valid.
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    // Regex sederhana untuk nomor telepon Indonesia (10-13 digit)
    final phoneRegex = RegExp(r'^(08)\d{8,11}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Format nomor telepon tidak valid (contoh: 08123456789)';
    }
    return null;
  }

  /// Memvalidasi field yang wajib diisi.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }
}
