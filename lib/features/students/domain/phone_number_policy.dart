enum GuardianPhoneCountry {
  yemen(countryCode: '+967'),
  saudiArabia(countryCode: '+966');

  const GuardianPhoneCountry({required this.countryCode});

  final String countryCode;
}

final class NormalizedPhoneNumber {
  const NormalizedPhoneNumber({
    required this.country,
    required this.nationalNumber,
  });

  final GuardianPhoneCountry country;
  final String nationalNumber;

  String get countryCode => country.countryCode;

  String get e164 => '$countryCode$nationalNumber';
}

final class PhoneNumberPolicy {
  const PhoneNumberPolicy();

  static const Set<String> _approvedYemenPrefixes = <String>{
    '70',
    '71',
    '73',
    '77',
    '78',
  };

  NormalizedPhoneNumber normalize({
    required GuardianPhoneCountry country,
    required String input,
  }) {
    final normalizedInput = _normalizeInputCharacters(input);

    if (normalizedInput.isEmpty) {
      throw const FormatException('Phone number is required.');
    }

    final nationalNumber = _extractNationalNumber(
      input: normalizedInput,
      country: country,
    );

    switch (country) {
      case GuardianPhoneCountry.yemen:
        _validateYemen(nationalNumber);

      case GuardianPhoneCountry.saudiArabia:
        _validateSaudiArabia(nationalNumber);
    }

    return NormalizedPhoneNumber(
      country: country,
      nationalNumber: nationalNumber,
    );
  }

  String _extractNationalNumber({
    required String input,
    required GuardianPhoneCountry country,
  }) {
    final callingCode = country.countryCode.substring(1);
    var value = input;

    if (value.startsWith('+')) {
      final expectedPrefix = '+$callingCode';

      if (!value.startsWith(expectedPrefix)) {
        throw const FormatException(
          'International country code does not match the selected country.',
        );
      }

      value = value.substring(expectedPrefix.length);
    } else if (value.startsWith('00')) {
      final expectedPrefix = '00$callingCode';

      if (!value.startsWith(expectedPrefix)) {
        throw const FormatException(
          'International country code does not match the selected country.',
        );
      }

      value = value.substring(expectedPrefix.length);
    } else if (value.startsWith(callingCode) && value.length > 9) {
      value = value.substring(callingCode.length);
    } else if (value.startsWith('0')) {
      value = value.substring(1);
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      throw const FormatException(
        'Phone number must contain digits only after normalization.',
      );
    }

    return value;
  }

  void _validateYemen(String nationalNumber) {
    if (nationalNumber.length != 9) {
      throw const FormatException(
        'Yemen mobile number must contain exactly 9 national digits.',
      );
    }

    final prefix = nationalNumber.substring(0, 2);

    if (!_approvedYemenPrefixes.contains(prefix)) {
      throw const FormatException('Yemen mobile prefix is not approved.');
    }
  }

  void _validateSaudiArabia(String nationalNumber) {
    if (nationalNumber.length != 9 || !nationalNumber.startsWith('5')) {
      throw const FormatException(
        'Saudi mobile number must contain 9 national digits starting with 5.',
      );
    }
  }

  String _normalizeInputCharacters(String input) {
    const arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
    const easternArabicDigits = '۰۱۲۳۴۵۶۷۸۹';

    final buffer = StringBuffer();

    for (final rune in input.trim().runes) {
      final character = String.fromCharCode(rune);

      final arabicIndicIndex = arabicIndicDigits.indexOf(character);
      if (arabicIndicIndex >= 0) {
        buffer.write(arabicIndicIndex);
        continue;
      }

      final easternArabicIndex = easternArabicDigits.indexOf(character);
      if (easternArabicIndex >= 0) {
        buffer.write(easternArabicIndex);
        continue;
      }

      if (character == ' ' ||
          character == '\t' ||
          character == '\n' ||
          character == '\r' ||
          character == '-' ||
          character == '(' ||
          character == ')') {
        continue;
      }

      buffer.write(character);
    }

    return buffer.toString();
  }
}
