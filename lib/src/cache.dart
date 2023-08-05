class Cache<K, V> {
  final V Function(K key) calc;

  Cache(this.calc);

  final _cache = <K, V>{};

  V get(K key) => _cache.putIfAbsent(key, () => calc(key));

  V call(K key) => get(key);
}

class TypedKey<T> {
  final Object key;

  TypedKey(this.key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypedKey && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;
}

extension TypedKeyObjectX on Object {
  TypedKey<T> asTypedKey<T>() => TypedKey(this);
}

class TypedCache {
  final _cache = <dynamic, dynamic Function()>{};

  void put<T>(TypedKey<T> key, T Function() calc) {
    _cache[key] = calc;
  }

  T? get<T>(TypedKey<T> key) {
    final calc = _cache[key] as T Function()?;
    if (calc == null) {
      return null;
    }
    return calc();
  }
}
