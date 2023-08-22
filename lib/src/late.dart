typedef Lazy<T> = T Function();

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

Late<T> lazy<T>(T Function() factory) => Late(factory);

class LateFinal<T> {
  late final T value;
}