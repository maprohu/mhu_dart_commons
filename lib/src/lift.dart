import 'dart:typed_data';

import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/src/functions.dart';
import 'package:protobuf/protobuf.dart';

import 'binary.dart';
import 'lift.dart' as $lib;
import 'proto.dart';

part 'lift.g.has.dart';

part 'lift.g.dart';

@Has()
typedef Higher<L, H> = H Function(L low);

@Has()
typedef Lower<L, H> = L Function(H high);

@Compose()
abstract class Lift<L, H> implements HasHigher<L, H>, HasLower<L, H> {}

BinaryLift<M> createBinaryProtoLift<M extends Msg>({
  @ext required CreateMsg<M> create,
}) {
  return ComposedLift<Bytes, M>(
      higher: (bytes) => create()
        ..mergeFromBuffer(bytes)
        ..freeze(),
      lower: (message) => message.writeToBuffer(),
    );
}

Lift<A, C> liftComposition<A, B, C>({
  @ext required Lift<A, B> lower,
  required Lift<B, C> higher,
}) {
  return ComposedLift<A, C>(
    higher: lower.higher.functionComposition$<C>(higher.higher),
    lower: higher.lower.functionComposition$<A>(lower.lower),
  );
}

typedef BinaryLift<T> = Lift<Bytes, T>;
