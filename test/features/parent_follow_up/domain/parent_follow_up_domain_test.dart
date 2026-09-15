import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';

void main() {
  group('Package 6 parent follow up domain', () {
    test('storage enums round trip through canonical values', () {
      for (final value in ParentFollowUpType.values) {
        expect(ParentFollowUpType.fromStorage(value.storageValue), value);
      }

      for (final value in ParentFollowUpStatus.values) {
        expect(ParentFollowUpStatus.fromStorage(value.storageValue), value);
      }

      for (final value in ParentFollowUpChannel.values) {
        expect(ParentFollowUpChannel.fromStorage(value.storageValue), value);
      }

      for (final value in ParentFollowUpAttendanceStatus.values) {
        expect(
          ParentFollowUpAttendanceStatus.fromStorage(value.storageValue),
          value,
        );
      }
    });

    test('Yemen can later snapshot either sms or whatsapp', () {
      expect(
        ParentFollowUpChannel.values,
        containsAll(<ParentFollowUpChannel>[
          ParentFollowUpChannel.sms,
          ParentFollowUpChannel.whatsapp,
        ]),
      );
    });

    test('pending and handled records expose explicit state', () {
      const pending = ParentFollowUpRecord(
        id: 1,
        dayId: 10,
        studentId: 20,
        type: ParentFollowUpType.daily,
        status: ParentFollowUpStatus.pending,
        correctsFollowUpId: null,
        handledSnapshot: null,
      );

      const handled = ParentFollowUpRecord(
        id: 2,
        dayId: 10,
        studentId: 20,
        type: ParentFollowUpType.daily,
        status: ParentFollowUpStatus.handled,
        correctsFollowUpId: null,
        handledSnapshot: ParentFollowUpHandledSnapshot(
          attendanceStatus: ParentFollowUpAttendanceStatus.present,
          message: 'رسالة فعلية',
          channel: ParentFollowUpChannel.whatsapp,
          recipient: '+967771234567',
        ),
      );

      expect(pending.isPending, isTrue);
      expect(pending.isHandled, isFalse);
      expect(pending.handledSnapshot, isNull);

      expect(handled.isHandled, isTrue);
      expect(handled.isPending, isFalse);
      expect(handled.handledSnapshot, isNotNull);
      expect(handled.handledSnapshot!.channel, ParentFollowUpChannel.whatsapp);
    });

    test('unsupported storage tokens fail explicitly', () {
      expect(() => ParentFollowUpType.fromStorage('other'), throwsStateError);
      expect(() => ParentFollowUpStatus.fromStorage('sent'), throwsStateError);
      expect(
        () => ParentFollowUpChannel.fromStorage('email'),
        throwsStateError,
      );
      expect(
        () => ParentFollowUpAttendanceStatus.fromStorage('late'),
        throwsStateError,
      );
    });
  });
}
