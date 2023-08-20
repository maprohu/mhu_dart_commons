import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/src/collection/compare.dart';
import 'package:rxdart/rxdart.dart';

import 'bidi.dart';
import 'cache.dart';
import 'editing.dart';
import 'functions.dart';
import 'dispose.dart';
import 'frp.dart' as frp;

part 'frp_ext.dart';

part 'frp_impl.dart';

part 'frp_fu.dart';

part 'frp_factory.dart';

part 'frp_cached.dart';

part 'frp_seq.dart';

part 'frp.g.has.dart';
// part 'frp.g.compose.dart';

typedef Watch<T> = T Function();
typedef Watch1<T, P1> = T Function(P1 p1);

abstract interface class Fr<T>  {
  T watch();

  T read();

  /// "changes" is not a great name since, by contract, the stream
  /// includes the initial, not yet changed value.
  /// maybe rename it to "distinctValues()" ?
  Stream<T> changes();
}


abstract interface class Fw<T> extends Fr<T> {
  void set(T value);

  factory Fw.fromFr({
    required Fr<T> fr,
    required void Function(T value) set,
  }) =>
      frw(fr, set);
}

mixin HasFr<T> implements Fr<T> {
  Fr<T> get fv$;

  @override
  T watch() => fv$.watch();

  @override
  T read() => fv$.read();

  @override
  Stream<T> changes() => fv$.changes();
}

mixin HasFw<T> implements Fw<T> {
  Fw<T> get fv$;

  @override
  T watch() => fv$.watch();

  @override
  T read() => fv$.read();

  @override
  Stream<T> changes() => fv$.changes();

  @override
  void set(T v) => fv$.set(v);
}
