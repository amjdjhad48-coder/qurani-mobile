import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/p0_spikes/p0_07_external_sharing_spike.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('qurani/p0_07_external_sharing_test');

  final spike = P007ExternalSharingSpike(channel: channel);

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('imo FileProvider launch requires narrow content share', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'shareImoProbe');

          return <String, Object?>{
            'launched': true,
            'kind': 'imo',
            'uri':
                'content://com.amjadjihad.qurani.p007.fileprovider/p0_07_share/p0_07_imo_probe.txt',
            'authority': 'com.amjadjihad.qurani.p007.fileprovider',
            'scheme': 'content',
            'fileName': 'p0_07_imo_probe.txt',
            'bytes': 84,
            'sha256':
                'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
            'dedicatedShareCache':
                '/data/user/0/com.amjadjihad.qurani/cache/p0_07_share',
            'cacheRoot': '/data/user/0/com.amjadjihad.qurani/cache',
          };
        });

    final result = await spike.shareImoProbe();

    expect(result.launched, isTrue);
    expect(result.kind, 'imo');
    expect(result.isNarrowContentShare, isTrue);
    expect(result.bytes, 84);
    expect(result.sha256.length, 64);
  });

  test('WhatsApp probe uses ACTION_SEND text/plain', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'shareWhatsAppText');

          return <String, Object?>{
            'launched': true,
            'kind': 'whatsapp',
            'action': 'android.intent.action.SEND',
            'mime': 'text/plain',
          };
        });

    final result = await spike.shareWhatsAppText();

    expect(result.launched, isTrue);
    expect(result.kind, 'whatsapp');
    expect(result.action, 'android.intent.action.SEND');
    expect(result.mime, 'text/plain');
  });

  test(
    'SMS probe uses ACTION_SENDTO smsto without direct-send permission',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'openSmsComposer');

            return <String, Object?>{
              'launched': true,
              'kind': 'sms',
              'action': 'android.intent.action.SENDTO',
              'uriScheme': 'smsto',
              'directSendPermissionRequired': false,
            };
          });

      final result = await spike.openSmsComposer();

      expect(result.launched, isTrue);
      expect(result.action, 'android.intent.action.SENDTO');
      expect(result.uriScheme, 'smsto');
      expect(result.directSendPermissionRequired, isFalse);
    },
  );

  test('external return state preserves chooser component', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getState');

          return <String, Object?>{
            'imo': <String, Object?>{
              'launchCount': 1,
              'pending': false,
              'pauseSeen': true,
              'returned': true,
              'chosenComponent': 'com.example.imo/.ShareActivity',
            },
            'whatsapp': <String, Object?>{
              'launchCount': 1,
              'pending': false,
              'pauseSeen': true,
              'returned': true,
              'chosenComponent': 'com.example.whatsapp/.ShareActivity',
            },
            'sms': <String, Object?>{
              'launchCount': 1,
              'pending': false,
              'pauseSeen': true,
              'returned': true,
              'chosenComponent': null,
            },
          };
        });

    final state = await spike.getState();

    expect(state.imo.returned, isTrue);
    expect(state.imo.pauseSeen, isTrue);
    expect(state.imo.chosenComponent, contains('imo'));

    expect(state.whatsapp.returned, isTrue);
    expect(state.whatsapp.chosenComponent, contains('whatsapp'));

    expect(state.sms.returned, isTrue);
    expect(state.sms.chosenComponent, isNull);
  });

  test('share cache cleanup reports no residue', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'cleanupShareProbe');

          return <String, Object?>{
            'existedBefore': true,
            'filesBefore': 1,
            'deleted': true,
            'existsAfter': false,
          };
        });

    final result = await spike.cleanupShareProbe();

    expect(result.cleaned, isTrue);
    expect(result.filesBefore, 1);
  });
}
