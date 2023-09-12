import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';

import 'functions.dart';

import 'late.dart' as $lib;

// part 'late.g.has.dart';
part 'late.g.dart';

typedef Lazy<T> = Call<T>;

class Late<T> {
  final T Function() _factory;

  late final value = _factory();

  Late(this._factory);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Late && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  T call() => value;
}

Late<T> lazyOf<T>(T Function() factory) => Late(factory);

class LateFinal<T> {
  late final T value;
}

Lazy<T> lazy<T>(
  @ext Call<T> factory,
) {
  late final T value = factory();
  return () => value;
}

class SingleAssign<T> {
  final Callback<T>? _callback;
  late final T _value;

  late Call<T> _getter;

  SingleAssign({
    Callback<T>? callback,
  }) : _callback = callback {
    _getter = () => _value;
  }

  SingleAssign.withDefault({
    Callback<T>? callback,
    required T defaultValue,
  }) : _callback = callback {
    _getter = () => defaultValue;
  }

  T get value => _getter();

  set value(T value) {
    _value = value;
    _getter = () => _value;
    _callback?.call(value);
  }
}
