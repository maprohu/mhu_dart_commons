import 'dart:typed_data';

extension MhuByteListX on List<int> {
  Uint8List get toUint8List => Uint8List.fromList(this);
}
