import 'package:qurani/core/security/local_security_state.dart';
import 'package:qurani/core/security/local_security_store.dart';

final class LocalSecurityStateStore {
  factory LocalSecurityStateStore({
    required LocalSecurityStore store,
    LocalSecurityStateV1Codec codec = const LocalSecurityStateV1Codec(),
  }) {
    return LocalSecurityStateStore._(store, codec);
  }

  const LocalSecurityStateStore._(this._store, this._codec);

  final LocalSecurityStore _store;
  final LocalSecurityStateV1Codec _codec;

  Future<LocalSecurityStateV1?> read() async {
    final payload = await _store.read();

    if (payload == null) {
      return null;
    }

    return _codec.decode(payload);
  }

  Future<void> write(LocalSecurityStateV1 state) {
    return _store.write(_codec.encode(state));
  }

  Future<void> clear() {
    return _store.clear();
  }
}
