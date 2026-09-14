import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/students/domain/phone_number_policy.dart';

void main() {
  const policy = PhoneNumberPolicy();

  group('PhoneNumberPolicy Yemen', () {
    test('accepts every approved Yemen prefix', () {
      for (final prefix in <String>['70', '71', '73', '77', '78']) {
        final result = policy.normalize(
          country: GuardianPhoneCountry.yemen,
          input: '${prefix}1234567',
        );

        expect(result.countryCode, '+967');
        expect(result.nationalNumber, '${prefix}1234567');
        expect(result.e164, '+967${prefix}1234567');
      }
    });

    test('normalizes Yemen national local and international forms', () {
      for (final input in <String>[
        '771234567',
        '0771234567',
        '+967771234567',
        '00967771234567',
        '967771234567',
        '+967 77 123 4567',
      ]) {
        final result = policy.normalize(
          country: GuardianPhoneCountry.yemen,
          input: input,
        );

        expect(result.countryCode, '+967');
        expect(result.nationalNumber, '771234567');
        expect(result.e164, '+967771234567');
      }
    });

    test('normalizes Arabic digits', () {
      final result = policy.normalize(
        country: GuardianPhoneCountry.yemen,
        input: '٠٧٧١٢٣٤٥٦٧',
      );

      expect(result.nationalNumber, '771234567');
      expect(result.e164, '+967771234567');
    });

    test('rejects unapproved Yemen prefixes', () {
      expect(
        () => policy.normalize(
          country: GuardianPhoneCountry.yemen,
          input: '721234567',
        ),
        throwsFormatException,
      );
    });

    test('rejects invalid Yemen length', () {
      expect(
        () => policy.normalize(
          country: GuardianPhoneCountry.yemen,
          input: '77123456',
        ),
        throwsFormatException,
      );
    });
  });

  group('PhoneNumberPolicy Saudi Arabia', () {
    test('normalizes Saudi national local and international forms', () {
      for (final input in <String>[
        '551234567',
        '0551234567',
        '+966551234567',
        '00966551234567',
        '966551234567',
        '+966 55 123 4567',
      ]) {
        final result = policy.normalize(
          country: GuardianPhoneCountry.saudiArabia,
          input: input,
        );

        expect(result.countryCode, '+966');
        expect(result.nationalNumber, '551234567');
        expect(result.e164, '+966551234567');
      }
    });

    test('normalizes Arabic Saudi digits', () {
      final result = policy.normalize(
        country: GuardianPhoneCountry.saudiArabia,
        input: '٠٥٥١٢٣٤٥٦٧',
      );

      expect(result.nationalNumber, '551234567');
      expect(result.e164, '+966551234567');
    });

    test('requires nine national digits starting with 5', () {
      for (final invalid in <String>['451234567', '55123456', '5512345678']) {
        expect(
          () => policy.normalize(
            country: GuardianPhoneCountry.saudiArabia,
            input: invalid,
          ),
          throwsFormatException,
        );
      }
    });
  });

  group('PhoneNumberPolicy country safety', () {
    test('rejects international number for a different selected country', () {
      expect(
        () => policy.normalize(
          country: GuardianPhoneCountry.yemen,
          input: '+966551234567',
        ),
        throwsFormatException,
      );

      expect(
        () => policy.normalize(
          country: GuardianPhoneCountry.saudiArabia,
          input: '+967771234567',
        ),
        throwsFormatException,
      );
    });

    test('rejects empty and alphabetic input', () {
      expect(
        () =>
            policy.normalize(country: GuardianPhoneCountry.yemen, input: '   '),
        throwsFormatException,
      );

      expect(
        () => policy.normalize(
          country: GuardianPhoneCountry.yemen,
          input: '77ABC4567',
        ),
        throwsFormatException,
      );
    });

    test('keeps country code separate from normalized national number', () {
      final result = policy.normalize(
        country: GuardianPhoneCountry.yemen,
        input: '+967771234567',
      );

      expect(result.countryCode, '+967');
      expect(result.nationalNumber, '771234567');
      expect(result.nationalNumber, isNot(startsWith('+967')));
    });
  });
}
