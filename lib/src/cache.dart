class Cache<K, V> {
  final V Function(K key) calc;

  Cache(this.calc);

  final _cache = <K, V>{};

  V get(K key) => _cache.putIfAbsent(key, () => calc(key));

  V call(K key) => get(key);
}
