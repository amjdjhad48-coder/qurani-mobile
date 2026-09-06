final class PinPolicy {
  PinPolicy._();

  static const int requiredLength = 6;

  static const Set<String> weakPatterns = <String>{
    '000000',
    '111111',
    '123456',
    '654321',
  };

  static final RegExp _sixDigits = RegExp(r'^\d{6}$');

  static bool isValid(String pin) {
    return _sixDigits.hasMatch(pin) && !weakPatterns.contains(pin);
  }
}
