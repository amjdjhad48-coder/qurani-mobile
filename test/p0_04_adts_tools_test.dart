import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/p0_spikes/p0_04_long_audio_spike.dart';

List<int> adtsFrame(int payloadLength) {
  final frameLength = 7 + payloadLength;

  return <int>[
    0xff,
    0xf1,
    0x50,
    0x40 | ((frameLength >> 11) & 0x03),
    (frameLength >> 3) & 0xff,
    ((frameLength & 0x07) << 5) | 0x1f,
    0xfc,
    ...List<int>.generate(payloadLength, (index) => index & 0xff),
  ];
}

void main() {
  test('P0-04 ADTS parser preserves complete frames and rejects tail', () {
    final first = adtsFrame(120);
    final second = adtsFrame(180);
    final complete = <int>[...first, ...second];
    final corrupted = <int>[...complete, 0xff, 0xf1, 0x50];

    expect(P004AdtsTools.countFrames(complete), 2);
    expect(P004AdtsTools.validPrefixLength(complete), complete.length);
    expect(P004AdtsTools.validPrefixLength(corrupted), complete.length);
  });
}
