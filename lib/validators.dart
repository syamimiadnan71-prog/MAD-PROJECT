class Validators {
  static final RegExp _uthmEmail =
      RegExp(r'^[a-zA-Z0-9._%+-]+@(student\.)?uthm\.edu\.my$');

  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Email tidak boleh kosong';
    if (!_uthmEmail.hasMatch(v)) {
      return 'Gunakan email UTHM (contoh: ali@student.uthm.edu.my)';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password tidak boleh kosong';
    if (v.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  static String? notEmpty(String? value, String field) {
    if ((value ?? '').trim().isEmpty) return '$field tidak boleh kosong';
    return null;
  }
}
