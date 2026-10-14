class Validators {
  Validators._();

  static String? required(String? value, {String fieldName = 'Kolom ini'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String fieldName = 'Input'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    if (value.trim().length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama pengguna tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama pengguna minimal 3 karakter';
    }
    return null;
  }

  static String? note(String? value, {bool isRequired = false}) {
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return 'Keterangan tidak boleh kosong';
    }
    if (value != null && value.trim().length > 250) {
      return 'Keterangan maksimal 250 karakter';
    }
    return null;
  }
}
