import 'package:flutter/services.dart';

final class P007ExternalSharingSpike {
  P007ExternalSharingSpike({MethodChannel? channel})
    : _channel =
          channel ?? const MethodChannel('qurani/p0_07_external_sharing');

  final MethodChannel _channel;

  Future<P007FileShareLaunch> shareImoProbe() async {
    final raw = await _channel.invokeMethod<Object?>('shareImoProbe');

    return P007FileShareLaunch.fromChannel(raw);
  }

  Future<P007TextShareLaunch> shareWhatsAppText() async {
    final raw = await _channel.invokeMethod<Object?>('shareWhatsAppText');

    return P007TextShareLaunch.fromChannel(raw);
  }

  Future<P007SmsLaunch> openSmsComposer() async {
    final raw = await _channel.invokeMethod<Object?>('openSmsComposer');

    return P007SmsLaunch.fromChannel(raw);
  }

  Future<P007ExternalSharingState> getState() async {
    final raw = await _channel.invokeMethod<Object?>('getState');

    return P007ExternalSharingState.fromChannel(raw);
  }

  Future<P007CleanupResult> cleanupShareProbe() async {
    final raw = await _channel.invokeMethod<Object?>('cleanupShareProbe');

    return P007CleanupResult.fromChannel(raw);
  }
}

final class P007FileShareLaunch {
  const P007FileShareLaunch({
    required this.launched,
    required this.kind,
    required this.uri,
    required this.authority,
    required this.scheme,
    required this.fileName,
    required this.bytes,
    required this.sha256,
    required this.dedicatedShareCache,
    required this.cacheRoot,
  });

  final bool launched;
  final String kind;
  final String uri;
  final String authority;
  final String scheme;
  final String fileName;
  final int bytes;
  final String sha256;
  final String dedicatedShareCache;
  final String cacheRoot;

  bool get isNarrowContentShare =>
      launched &&
      scheme == 'content' &&
      authority.endsWith('.p007.fileprovider') &&
      dedicatedShareCache.startsWith(cacheRoot) &&
      fileName == 'p0_07_imo_probe.txt';

  factory P007FileShareLaunch.fromChannel(Object? raw) {
    final map = _stringKeyedMap(raw);

    return P007FileShareLaunch(
      launched: _requiredBool(map, 'launched'),
      kind: _requiredString(map, 'kind'),
      uri: _requiredString(map, 'uri'),
      authority: _requiredString(map, 'authority'),
      scheme: _requiredString(map, 'scheme'),
      fileName: _requiredString(map, 'fileName'),
      bytes: _requiredInt(map, 'bytes'),
      sha256: _requiredString(map, 'sha256'),
      dedicatedShareCache: _requiredString(map, 'dedicatedShareCache'),
      cacheRoot: _requiredString(map, 'cacheRoot'),
    );
  }
}

final class P007TextShareLaunch {
  const P007TextShareLaunch({
    required this.launched,
    required this.kind,
    required this.action,
    required this.mime,
  });

  final bool launched;
  final String kind;
  final String action;
  final String mime;

  factory P007TextShareLaunch.fromChannel(Object? raw) {
    final map = _stringKeyedMap(raw);

    return P007TextShareLaunch(
      launched: _requiredBool(map, 'launched'),
      kind: _requiredString(map, 'kind'),
      action: _requiredString(map, 'action'),
      mime: _requiredString(map, 'mime'),
    );
  }
}

final class P007SmsLaunch {
  const P007SmsLaunch({
    required this.launched,
    required this.kind,
    required this.action,
    required this.uriScheme,
    required this.directSendPermissionRequired,
  });

  final bool launched;
  final String kind;
  final String action;
  final String uriScheme;
  final bool directSendPermissionRequired;

  factory P007SmsLaunch.fromChannel(Object? raw) {
    final map = _stringKeyedMap(raw);

    return P007SmsLaunch(
      launched: _requiredBool(map, 'launched'),
      kind: _requiredString(map, 'kind'),
      action: _requiredString(map, 'action'),
      uriScheme: _requiredString(map, 'uriScheme'),
      directSendPermissionRequired: _requiredBool(
        map,
        'directSendPermissionRequired',
      ),
    );
  }
}

final class P007ExternalActionState {
  const P007ExternalActionState({
    required this.launchCount,
    required this.pending,
    required this.pauseSeen,
    required this.returned,
    required this.chosenComponent,
  });

  final int launchCount;
  final bool pending;
  final bool pauseSeen;
  final bool returned;
  final String? chosenComponent;

  factory P007ExternalActionState.fromChannel(Object? raw) {
    final map = _stringKeyedMap(raw);

    return P007ExternalActionState(
      launchCount: _requiredInt(map, 'launchCount'),
      pending: _requiredBool(map, 'pending'),
      pauseSeen: _requiredBool(map, 'pauseSeen'),
      returned: _requiredBool(map, 'returned'),
      chosenComponent: _optionalString(map, 'chosenComponent'),
    );
  }
}

final class P007ExternalSharingState {
  const P007ExternalSharingState({
    required this.imo,
    required this.whatsapp,
    required this.sms,
  });

  final P007ExternalActionState imo;
  final P007ExternalActionState whatsapp;
  final P007ExternalActionState sms;

  factory P007ExternalSharingState.fromChannel(Object? raw) {
    final map = _stringKeyedMap(raw);

    return P007ExternalSharingState(
      imo: P007ExternalActionState.fromChannel(map['imo']),
      whatsapp: P007ExternalActionState.fromChannel(map['whatsapp']),
      sms: P007ExternalActionState.fromChannel(map['sms']),
    );
  }
}

final class P007CleanupResult {
  const P007CleanupResult({
    required this.existedBefore,
    required this.filesBefore,
    required this.deleted,
    required this.existsAfter,
  });

  final bool existedBefore;
  final int filesBefore;
  final bool deleted;
  final bool existsAfter;

  bool get cleaned => deleted && !existsAfter;

  factory P007CleanupResult.fromChannel(Object? raw) {
    final map = _stringKeyedMap(raw);

    return P007CleanupResult(
      existedBefore: _requiredBool(map, 'existedBefore'),
      filesBefore: _requiredInt(map, 'filesBefore'),
      deleted: _requiredBool(map, 'deleted'),
      existsAfter: _requiredBool(map, 'existsAfter'),
    );
  }
}

Map<String, Object?> _stringKeyedMap(Object? raw) {
  if (raw is! Map) {
    throw const FormatException('Expected a map from P0-07 native bridge.');
  }

  return raw.map((key, value) => MapEntry(key.toString(), value));
}

String _requiredString(Map<String, Object?> map, String key) {
  final value = map[key];

  if (value is! String || value.isEmpty) {
    throw FormatException('Missing/invalid P0-07 string: $key');
  }

  return value;
}

String? _optionalString(Map<String, Object?> map, String key) {
  final value = map[key];

  if (value == null) {
    return null;
  }

  if (value is! String || value.isEmpty) {
    throw FormatException('Invalid P0-07 optional string: $key');
  }

  return value;
}

bool _requiredBool(Map<String, Object?> map, String key) {
  final value = map[key];

  if (value is! bool) {
    throw FormatException('Missing/invalid P0-07 bool: $key');
  }

  return value;
}

int _requiredInt(Map<String, Object?> map, String key) {
  final value = map[key];

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  throw FormatException('Missing/invalid P0-07 int: $key');
}
