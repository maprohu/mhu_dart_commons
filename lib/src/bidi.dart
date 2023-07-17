import 'dart:convert';
import 'dart:typed_data';

import 'package:mhu_dart_commons/src/kt.dart';
import 'package:protobuf/protobuf.dart';

import 'functions.dart' as functions;

abstract interface class BiDi<A, B> {
  B forward(A a);

  A backward(B b);

  static final BiDi<List<int>, Uint8List> listOfIntToUint8List = BiDi(
    forward: Uint8List.fromList,
    backward: functions.identity,
  );

  static final BiDi<String, dynamic> jsonString = BiDi(
    forward: jsonDecode,
    backward: jsonEncode,
  );

  static final BiDi<String, Map<String, dynamic>> jsonObjectString =
      jsonString.bidiCast();

  factory BiDi({
    required B Function(A a) forward,
    required A Function(B b) backward,
  }) = _BiDiImpl;



  static BiDi<A, C> compose<A, B, C>({
    required BiDi<A, B> aToB,
    required BiDi<B, C> bToC,
  }) =>
      BiDi(
        forward: (a) => bToC.forward(aToB.forward(a)),
        backward: (c) => aToB.backward(bToC.backward(c)),
      );

  static BiDi<List<int>, M> protoIntList<M extends GeneratedMessage>(
      M Function() create,
      ) =>
      BiDi.listOfIntToUint8List.andThen(proto<M>(create));

  static BiDi<Uint8List, M> proto<M extends GeneratedMessage>(
      M Function() create,
      ) =>
      BiDi(
        forward: (bytes) => create()
          ..mergeFromBuffer(bytes)
          ..freeze(),
        backward: (message) => message.writeToBuffer(),
      );

  static BiDi<Map<String, dynamic>, M> protoJson<M extends GeneratedMessage>(
      M Function() create,
      ) =>
      BiDi(
        forward: (map) => create()
          ..mergeFromProto3Json(map, ignoreUnknownFields: true)
          ..freeze(),
        backward: (message) => message.toProto3Json() as Map<String, dynamic>,
      );

  static BiDiOpt<A, B> bidiOpt<A, B>(BiDi<A, B> bidi) => BiDi(
    forward: (a) => a?.let(bidi.forward),
    backward: (b) => b?.let(bidi.backward),
  );

  static BiDi<T, T> identity<T>() => BiDi(
    forward: functions.identity,
    backward: functions.identity,
  );

  static BiDi<A, B> bidiCast<A, B>() => BiDi(
    forward: (a) => a as B,
    backward: (b) => b as A,
  );

  static BiDi<A, B> bidiCastNarrow<A, B extends A>() => BiDi(
    forward: (a) => a as B,
    backward: (b) => b,
  );

  static BiDi<P, E> protobufEnumByIndex<P extends ProtobufEnum, E extends Enum>(
      List<P> pbValues,
      List<E> enumValues,
      ) {
    assert(pbValues.length == enumValues.length);

    return BiDi(
      forward: (pb) => enumValues[pb.value],
      backward: (enm) => pbValues[enm.index],
    );
  }
}

class _BiDiImpl<A, B> implements BiDi<A, B> {
  final B Function(A a) _forward;
  final A Function(B b) _backward;

  const _BiDiImpl({
    required B Function(A a) forward,
    required A Function(B b) backward,
  })  : _forward = forward,
        _backward = backward;

  @override
  A backward(B b) => _backward(b);

  @override
  B forward(A a) => _forward(a);
}

typedef BiDiOpt<A, B> = BiDi<A?, B?>;


extension BiDiX<A, B> on BiDi<A, B> {
  BiDi<A, C> andThen<C>(BiDi<B, C> bidi) => BiDi.compose(
        aToB: this,
        bToC: bidi,
      );

  BiDiOpt<A, B> bidiOpt() => BiDi.bidiOpt(this);

  BiDi<A, C> bidiCast<C>() => andThen(BiDi.bidiCast<B, C>());

  BiDi<A, C> map<C>({
    required C Function(B a) forward,
    required B Function(C b) backward,
  }) =>
      andThen(
        BiDi(
          forward: forward,
          backward: backward,
        ),
      );
}

extension BiDiOptX<A, B> on BiDiOpt<A, B> {
  BiDiOpt<A, C> andThenOpt<C>(BiDi<B, C> bidi) =>
      andThen(bidi.bidiOpt());
}

