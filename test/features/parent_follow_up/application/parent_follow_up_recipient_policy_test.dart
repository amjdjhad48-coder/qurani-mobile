import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_recipient_policy.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_dispatch.dart';

void main() {
  const policy = ParentFollowUpRecipientPolicy();

  group('Package 6 parent follow up recipient policy', () {
    test('Yemen allows teacher to choose sms or whatsapp', () {
      final result = policy.resolve(
        studentId: 10,
        countryCode: '+967',
        nationalNumber: '0771234567',
      );

      expect(result.requiresPhoneFix, isFalse);
      expect(result.recipient, '+967771234567');
      expect(result.allowedChannels, <ParentFollowUpChannel>[
        ParentFollowUpChannel.sms,
        ParentFollowUpChannel.whatsapp,
      ]);

      expect(
        result.requireRecipient(ParentFollowUpChannel.sms),
        '+967771234567',
      );

      expect(
        result.requireRecipient(ParentFollowUpChannel.whatsapp),
        '+967771234567',
      );
    });

    test('Saudi Arabia allows whatsapp and rejects sms', () {
      final result = policy.resolve(
        studentId: 20,
        countryCode: '+966',
        nationalNumber: '0551234567',
      );

      expect(result.requiresPhoneFix, isFalse);
      expect(result.recipient, '+966551234567');

      expect(result.allowedChannels, <ParentFollowUpChannel>[
        ParentFollowUpChannel.whatsapp,
      ]);

      expect(
        result.requireRecipient(ParentFollowUpChannel.whatsapp),
        '+966551234567',
      );

      expect(
        () => result.requireRecipient(ParentFollowUpChannel.sms),
        throwsA(isA<ParentFollowUpChannelNotAllowedException>()),
      );
    });

    test('invalid stored number requires phone fix', () {
      final result = policy.resolve(
        studentId: 30,
        countryCode: '+967',
        nationalNumber: '721234567',
      );

      expect(result.requiresPhoneFix, isTrue);
      expect(result.recipient, isNull);
      expect(result.allowedChannels, isEmpty);

      expect(
        () => result.requireRecipient(ParentFollowUpChannel.whatsapp),
        throwsA(
          isA<ParentFollowUpPhoneFixRequiredException>().having(
            (error) => error.studentId,
            'studentId',
            30,
          ),
        ),
      );
    });

    test('unsupported country requires phone fix', () {
      final result = policy.resolve(
        studentId: 40,
        countryCode: '+971',
        nationalNumber: '501234567',
      );

      expect(result.requiresPhoneFix, isTrue);
      expect(result.recipient, isNull);
      expect(result.allowedChannels, isEmpty);
    });
  });
}
