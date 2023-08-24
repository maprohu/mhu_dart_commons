mixin HolderMixin<T> {
  T get value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HolderMixin &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class Holder<T> with HolderMixin<T> {
  @override
  final T value;

  Holder(this.value);
}
