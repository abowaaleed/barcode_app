class ValidationResult {
  final bool isValid;
  final String? error;
  const ValidationResult({this.isValid = true, this.error});
}

class Validators {
  static ValidationResult validatePhone(String phone) {
    if (phone.isEmpty) return const ValidationResult(error: 'رقم الهاتف مطلوب');
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 8) return const ValidationResult(error: 'رقم الهاتف قصير جداً');
    if (!RegExp(r'^\+?\d+$').hasMatch(cleaned)) return const ValidationResult(error: 'رقم الهاتف يجب أن يحتوي أرقاماً فقط');
    return const ValidationResult();
  }

  static ValidationResult validateEmail(String email) {
    if (email.isEmpty) return const ValidationResult(error: 'البريد الإلكتروني مطلوب');
    if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.\w{2,}$').hasMatch(email)) return const ValidationResult(error: 'البريد الإلكتروني غير صحيح');
    return const ValidationResult();
  }

  static ValidationResult validateUrl(String url) {
    if (url.isEmpty) return const ValidationResult(error: 'الرابط مطلوب');
    final u = url.startsWith('http') ? url : 'https://$url';
    if (!Uri.tryParse(u)!.hasAbsolutePath) return const ValidationResult(error: 'الرابط غير صحيح');
    return const ValidationResult();
  }

  static ValidationResult validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) return ValidationResult(error: '$fieldName مطلوب');
    return const ValidationResult();
  }

  static ValidationResult validateSsid(String ssid) {
    if (ssid.trim().isEmpty) return const ValidationResult(error: 'اسم الشبكة (SSID) مطلوب');
    return const ValidationResult();
  }

  static ValidationResult validateCryptoAddress(String address, String currency) {
    if (address.isEmpty) return const ValidationResult(error: 'عنوان المحفظة مطلوب');
    switch (currency) {
      case 'bitcoin':
        if (!address.startsWith('1') && !address.startsWith('3') && !address.startsWith('bc1')) {
          return const ValidationResult(error: 'عنوان بيتكوين غير صالح');
        }
        if (address.length < 26 || address.length > 62) {
          return const ValidationResult(error: 'طول عنوان بيتكوين غير صحيح');
        }
        break;
      case 'ethereum':
        if (!address.startsWith('0x')) return const ValidationResult(error: 'عنوان إيثريوم يجب أن يبدأ بـ 0x');
        if (address.length != 42) return const ValidationResult(error: 'طول عنوان إيثريوم يجب أن يكون 42 حرفاً');
        break;
    }
    return const ValidationResult();
  }

  static ValidationResult validateTotpSecret(String secret) {
    if (secret.isEmpty) return const ValidationResult(error: 'المفتاح السري مطلوب');
    if (secret.length < 16) return const ValidationResult(error: 'المفتاح السري قصير جداً (16 حرفاً على الأقل)');
    if (!RegExp(r'^[A-Za-z2-7]+=*$').hasMatch(secret)) return const ValidationResult(error: 'المفتاح السري يحتوي أحرفاً غير صالحة (Base32)');
    return const ValidationResult();
  }

  static ValidationResult validateBarcode(String code, {bool isUpc = true}) {
    if (code.isEmpty) return const ValidationResult(error: 'رمز المنتج مطلوب');
    if (!RegExp(r'^\d+$').hasMatch(code)) return const ValidationResult(error: 'رمز المنتج يجب أن يكون أرقاماً فقط');
    if (isUpc && code.length != 12) return const ValidationResult(error: 'رمز UPC-A يجب أن يحتوي 12 رقماً');
    if (!isUpc && code.length != 13) return const ValidationResult(error: 'رمز EAN-13 يجب أن يحتوي 13 رقماً');
    return const ValidationResult();
  }
}
