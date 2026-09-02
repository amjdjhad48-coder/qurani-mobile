import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:qurani/p0_spikes/p0_05_real_excel_pdf_spike.dart';

final class P006SafResult {
  const P006SafResult({
    required this.status,
    required this.suggestedName,
    required this.mimeType,
    this.uri,
    this.bytes,
    this.reopenedBytes,
    this.sha256,
    this.reopenedSha256,
    this.roundTripMatches,
  });

  final String status;
  final String suggestedName;
  final String mimeType;
  final String? uri;
  final int? bytes;
  final int? reopenedBytes;
  final String? sha256;
  final String? reopenedSha256;
  final bool? roundTripMatches;

  bool get isSaved => status == 'saved';
  bool get isCancelled => status == 'cancelled';

  factory P006SafResult.fromPlatform(Object? raw) {
    if (raw is! Map) {
      throw StateError('Invalid P0-06 SAF result: $raw');
    }

    final map = Map<Object?, Object?>.from(raw);

    final status = map['status'];
    final suggestedName = map['suggestedName'];
    final mimeType = map['mimeType'];

    if (status is! String || suggestedName is! String || mimeType is! String) {
      throw StateError('Incomplete P0-06 SAF result: $map');
    }

    return P006SafResult(
      status: status,
      suggestedName: suggestedName,
      mimeType: mimeType,
      uri: map['uri'] as String?,
      bytes: map['bytes'] as int?,
      reopenedBytes: map['reopenedBytes'] as int?,
      sha256: map['sha256'] as String?,
      reopenedSha256: map['reopenedSha256'] as String?,
      roundTripMatches: map['roundTripMatches'] as bool?,
    );
  }
}

final class P006SafBridge {
  P006SafBridge({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'qurani/p0_06_saf';

  final MethodChannel _channel;

  Future<P006SafResult> saveBytes({
    required Uint8List bytes,
    required String suggestedName,
    required String mimeType,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes, 'bytes', 'must not be empty');
    }

    final name = suggestedName.trim();
    if (name.isEmpty || name.contains('/') || name.contains(r'\')) {
      throw ArgumentError.value(
        suggestedName,
        'suggestedName',
        'must be a simple file name',
      );
    }

    final mime = mimeType.trim();
    if (mime.isEmpty) {
      throw ArgumentError.value(mimeType, 'mimeType', 'must not be empty');
    }

    final raw = await _channel.invokeMethod<Object?>(
      'saveBytes',
      <String, Object>{'bytes': bytes, 'suggestedName': name, 'mimeType': mime},
    );

    final result = P006SafResult.fromPlatform(raw);

    if (result.isSaved) {
      if (result.uri == null ||
          result.bytes != bytes.length ||
          result.reopenedBytes != bytes.length ||
          result.sha256 == null ||
          result.reopenedSha256 == null ||
          result.sha256 != result.reopenedSha256 ||
          result.roundTripMatches != true) {
        throw StateError('P0-06 SAF round-trip proof is incomplete: $raw');
      }
    } else if (!result.isCancelled) {
      throw StateError('Unexpected P0-06 SAF status: ${result.status}');
    }

    return result;
  }
}

final class P006SafProbe {
  P006SafProbe({P006SafBridge? bridge}) : _bridge = bridge ?? P006SafBridge();

  static const String xlsxMime =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  static const String qrbMime = 'application/octet-stream';

  final P006SafBridge _bridge;

  Future<P006SafResult> saveReportXlsx() {
    return _bridge.saveBytes(
      bytes: P005RealExcelPdfSpike.buildArabicExcel(),
      suggestedName: 'report.xlsx',
      mimeType: xlsxMime,
    );
  }

  Future<P006SafResult> saveQrbProbe() {
    return _bridge.saveBytes(
      bytes: qrbProbeBytes(),
      suggestedName: 'qurani_p0_06_probe.qrb',
      mimeType: qrbMime,
    );
  }

  Future<P006SafResult> startCancellationProbe() {
    return _bridge.saveBytes(
      bytes: qrbProbeBytes(),
      suggestedName: 'qurani_p0_06_cancel_probe.qrb',
      mimeType: qrbMime,
    );
  }

  static Uint8List qrbProbeBytes() {
    return Uint8List.fromList(
      utf8.encode(
        'QURANI-P0-06-QRB-PROBE\n'
        'NOT_PRODUCTION_QRB_FORMAT\n'
        'version=1\n'
        'purpose=SAF_WRITE_READBACK_ONLY\n',
      ),
    );
  }
}
