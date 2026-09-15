import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/parent_follow_up/data/android_parent_follow_up_external_gateway.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('qurani/p6_06_parent_follow_up_gateway_test');

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('WhatsApp passes exact prepared recipient and message', () async {
    const payload = PreparedParentFollowUpPayload(
      followUpId: 1,
      attendanceStatus: ParentFollowUpAttendanceStatus.absent,
      message: 'الرسالة الفعلية كما ظهرت في المعاينة',
      channel: ParentFollowUpChannel.whatsapp,
      recipient: '+967771234567',
    );

    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'openParentWhatsApp');

      expect(call.arguments, <String, Object?>{
        'recipient': '+967771234567',
        'message': 'الرسالة الفعلية كما ظهرت في المعاينة',
      });

      return <String, Object?>{
        'launched': true,
        'kind': 'whatsapp',
        'action': 'android.intent.action.VIEW',
        'uriScheme': 'https',
        'recipient': '+967771234567',
      };
    });

    final gateway = AndroidParentFollowUpExternalGateway(channel: channel);

    final result = await gateway.open(payload);

    expect(result.launched, isTrue);
    expect(result.channel, ParentFollowUpChannel.whatsapp);
    expect(result.uriScheme, 'https');
    expect(result.recipient, payload.recipient);
  });

  test('SMS passes exact prepared recipient and body', () async {
    const payload = PreparedParentFollowUpPayload(
      followUpId: 2,
      attendanceStatus: ParentFollowUpAttendanceStatus.present,
      message: 'نص SMS الفعلي',
      channel: ParentFollowUpChannel.sms,
      recipient: '+967731234567',
    );

    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'openParentSms');

      expect(call.arguments, <String, Object?>{
        'recipient': '+967731234567',
        'message': 'نص SMS الفعلي',
      });

      return <String, Object?>{
        'launched': true,
        'kind': 'sms',
        'action': 'android.intent.action.SENDTO',
        'uriScheme': 'smsto',
        'recipient': '+967731234567',
        'directSendPermissionRequired': false,
      };
    });

    final gateway = AndroidParentFollowUpExternalGateway(channel: channel);

    final result = await gateway.open(payload);

    expect(result.launched, isTrue);
    expect(result.channel, ParentFollowUpChannel.sms);
    expect(result.uriScheme, 'smsto');
    expect(result.recipient, payload.recipient);
  });

  test('gateway rejects mismatched recipient response', () async {
    const payload = PreparedParentFollowUpPayload(
      followUpId: 3,
      attendanceStatus: ParentFollowUpAttendanceStatus.present,
      message: 'رسالة',
      channel: ParentFollowUpChannel.whatsapp,
      recipient: '+966551234567',
    );

    messenger.setMockMethodCallHandler(
      channel,
      (_) async => <String, Object?>{
        'launched': true,
        'kind': 'whatsapp',
        'action': 'android.intent.action.VIEW',
        'uriScheme': 'https',
        'recipient': '+966599999999',
      },
    );

    final gateway = AndroidParentFollowUpExternalGateway(channel: channel);

    await expectLater(gateway.open(payload), throwsStateError);
  });
}
