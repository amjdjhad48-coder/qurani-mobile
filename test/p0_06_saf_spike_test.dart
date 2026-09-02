import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/p0_spikes/p0_06_saf_spike.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(P006SafBridge.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'report.xlsx request uses XLSX MIME and validates saved round-trip',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'saveBytes');

        final args = Map<Object?, Object?>.from(call.arguments as Map);
        expect(args['suggestedName'], 'report.xlsx');
        expect(args['mimeType'], P006SafProbe.xlsxMime);

        final bytes = args['bytes'];
        expect(bytes, isA<Uint8List>());

        final typed = bytes! as Uint8List;
        expect(typed.length, greaterThan(1000));
        expect(typed[0], 0x50);
        expect(typed[1], 0x4b);

        return <String, Object?>{
          'status': 'saved',
          'uri': 'content://test/primary%3ADownload%2Freport.xlsx',
          'bytes': typed.length,
          'reopenedBytes': typed.length,
          'sha256': 'ABC123',
          'reopenedSha256': 'ABC123',
          'roundTripMatches': true,
          'suggestedName': 'report.xlsx',
          'mimeType': P006SafProbe.xlsxMime,
        };
      });

      final result = await P006SafProbe(
        bridge: P006SafBridge(channel: channel),
      ).saveReportXlsx();

      expect(result.isSaved, isTrue);
      expect(result.roundTripMatches, isTrue);
      expect(result.uri, contains('Download'));
    },
  );

  test('qrb probe is explicitly non-production and uses .qrb name', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      final args = Map<Object?, Object?>.from(call.arguments as Map);
      expect(args['suggestedName'], 'qurani_p0_06_probe.qrb');
      expect(args['mimeType'], P006SafProbe.qrbMime);

      final bytes = args['bytes']! as Uint8List;
      final text = utf8.decode(bytes);

      expect(text, startsWith('QURANI-P0-06-QRB-PROBE'));
      expect(text, contains('NOT_PRODUCTION_QRB_FORMAT'));

      return <String, Object?>{
        'status': 'saved',
        'uri': 'content://test/primary%3ADocuments%2Fqurani_p0_06_probe.qrb',
        'bytes': bytes.length,
        'reopenedBytes': bytes.length,
        'sha256': 'DEF456',
        'reopenedSha256': 'DEF456',
        'roundTripMatches': true,
        'suggestedName': 'qurani_p0_06_probe.qrb',
        'mimeType': P006SafProbe.qrbMime,
      };
    });

    final result = await P006SafProbe(
      bridge: P006SafBridge(channel: channel),
    ).saveQrbProbe();

    expect(result.isSaved, isTrue);
    expect(result.uri, contains('Documents'));
  });

  test(
    'user cancellation is a normal result and not a false success',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        final args = Map<Object?, Object?>.from(call.arguments as Map);

        return <String, Object?>{
          'status': 'cancelled',
          'suggestedName': args['suggestedName']! as String,
          'mimeType': args['mimeType']! as String,
        };
      });

      final result = await P006SafProbe(
        bridge: P006SafBridge(channel: channel),
      ).startCancellationProbe();

      expect(result.isCancelled, isTrue);
      expect(result.isSaved, isFalse);
      expect(result.uri, isNull);
    },
  );

  test(
    'bridge rejects invalid empty/path-like requests before platform call',
    () async {
      final bridge = P006SafBridge(channel: channel);

      await expectLater(
        bridge.saveBytes(
          bytes: Uint8List(0),
          suggestedName: 'empty.qrb',
          mimeType: P006SafProbe.qrbMime,
        ),
        throwsArgumentError,
      );

      await expectLater(
        bridge.saveBytes(
          bytes: Uint8List.fromList(<int>[1]),
          suggestedName: '../bad.qrb',
          mimeType: P006SafProbe.qrbMime,
        ),
        throwsArgumentError,
      );
    },
  );
}
