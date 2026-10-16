class Validators {
  Validators._();

  // Regex untuk validasi format email standar
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  /// Validasi username atau email:
  /// - Tidak boleh kosong
  /// - Minimal 3 karakter
  /// - Jika mengandung '@', harus memenuhi format email yang valid
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username / email tidak boleh kosong';
    }
    final trimmed = value.trim();
    if (trimmed.length < 6) {
      return 'Username / email minimal 6 karakter';
    }
    // Jika input mengandung '@', validasi sebagai email
    if (trimmed.contains('@')) {
      if (!_emailRegex.hasMatch(trimmed)) {
        return 'Format email tidak valid';
      }
    }
    return null;
  }

  /// Validasi password:
  /// - Tidak boleh kosong
  /// - Minimal 6 karakter
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Validator generik: kolom tidak boleh kosong
  static String? required(String? value, {String fieldName = 'Kolom ini'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Validator generik: minimal panjang karakter
  static String? minLength(
    String? value,
    int min, {
    String fieldName = 'Input',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    if (value.trim().length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }

  /// Validator untuk field catatan/keterangan (opsional/wajib, maks 200 karakter)
  static String? note(String? value, {bool isRequired = false, int maxLength = 200}) {
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return 'Keterangan tidak boleh kosong';
    }
    if (value != null && value.trim().length > maxLength) {
      return 'Keterangan maksimal $maxLength karakter';
    }
    return null;
  }
}
