import 'dart:typed_data';

import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';

part 'binary.g.has.dart';

@Has()
typedef Bytes = List<int>;

extension MhuByteListX on List<int> {
  Uint8List get toUint8List => Uint8List.fromList(this);
}
