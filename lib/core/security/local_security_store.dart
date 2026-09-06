import 'dart:typed_data';

abstract interface class LocalSecurityStore {
  Future<Uint8List?> read();

  Future<void> write(Uint8List payload);

  Future<void> clear();
}
