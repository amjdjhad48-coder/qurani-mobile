import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/security/pin_policy.dart';

void main() {
  group('PinPolicy', () {
    test('requires exactly six decimal digits', () {
      expect(PinPolicy.isValid('482731'), isTrue);

      expect(PinPolicy.isValid('48273'), isFalse);
      expect(PinPolicy.isValid('4827310'), isFalse);
      expect(PinPolicy.isValid('48a731'), isFalse);
      expect(PinPolicy.isValid('٤٨٢٧٣١'), isFalse);
      expect(PinPolicy.isValid(' 482731'), isFalse);
    });

    test('rejects the explicitly approved weak patterns', () {
      for (final pin in PinPolicy.weakPatterns) {
        expect(
          PinPolicy.isValid(pin),
          isFalse,
          reason: 'Weak PIN must be rejected: $pin',
        );
      }
    });

    test('does not invent broader weak-PIN rules', () {
      expect(PinPolicy.isValid('222222'), isTrue);
      expect(PinPolicy.isValid('012345'), isTrue);
      expect(PinPolicy.isValid('543210'), isTrue);
    });

    test('keeps the approved PIN length contract', () {
      expect(PinPolicy.requiredLength, 6);
      expect(
        PinPolicy.weakPatterns,
        unorderedEquals(<String>{'000000', '111111', '123456', '654321'}),
      );
    });
  });
}
