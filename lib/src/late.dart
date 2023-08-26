import 'functions.dart';

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

Lazy<T> lazy<T>(Call<T> factory) {
  late final T value = factory();
  return () => value;
}
