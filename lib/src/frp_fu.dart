part of 'frp.dart';

abstract interface class Fu<T> extends Fr<T> {
  void update(void Function(T items) updates);
}

mixin HasFu<T> implements Fu<T> {
  Fu<T> get fv;

  @override
  T watch() => fv.watch();

  @override
  T read() => fv.read();

  @override
  Stream<T> changes() => fv.changes();

  @override
  void update(void Function(T items) updates) => fv.update(updates);
}

typedef MapFu<K, V> = CachedFu<V, K, Map<K, V>, Fw<V>>;
typedef ListFu<V> = CachedFu<V, int, List<V>, Fw<V>>;

class CachedFu<T, K, C, F extends Fw<T>> with HasFu<C> {
  @override
  final Fu<C> fv;
  final F Function(K key) _item;
  final T? Function(C collection, K key) _get;
  final Iterable<K> Function(C collecion) _keys;
  final Iterable<K> Function(C collecion) _sortedKeys;
  final DspReg? _disposers;

  F item(K key) => _item(key);

  late final _getCache = Cache<K, Fr<T?>>((key) {
    return fr(
          () => _get(fv(), key),
      disposers: _disposers,
    );
  });

  Fr<T?> get(K key) => _getCache.get(key);

  late final _existsCache = Cache<K, Fr<bool>>((key) {
    final getFr = get(key);
    return fr(
          () => getFr() != null,
      disposers: _disposers,
    );
  });

  Fr<bool> exists(K key) => _existsCache.get(key);

  late final keys = fr(
        () => _keys(fv()),
    disposers: _disposers,
  );

  late final sortedKeys = fr(
        () => _sortedKeys(fv()),
    disposers: _disposers,
  );

  static CachedFu<T, int, List<T>, F> list<T, F extends Fw<T>>({
    required Fu<List<T>> fv,
    required F Function(Fw<T> item) wrap,
    T? defaultValue,
    DspReg? disposers,
  }) {
    final cache = Cache<int, F>((index) {
      final item = fv.itemFwHot(
        index,
        defaultValue: defaultValue,
        disposers: disposers,
      );
      return wrap(item);
    });
    return CachedFu(
      fv: fv,
      item: cache.get,
      get: (collection, key) =>
      key < collection.length ? collection[key] : null,
      keys: (collecion) => collecion.mapIndexed((index, element) => index),
      sortedKeys: (collecion) =>
          collecion.mapIndexed((index, element) => index),
      disposers: disposers,
    );
  }

  static CachedFu<T, K, Map<K, T>, F> map<T, K, F extends Fw<T>>({
    required Fu<Map<K, T>> fv,
    required F Function(Fw<T> item) wrap,
    T? defaultValue,
    DspReg? disposers,
  }) {
    final cache = Cache<K, F>((index) {
      final item = fv.itemFwHot(
        index,
        defaultValue: defaultValue,
        disposers: disposers,
      );
      return wrap(item);
    });
    return CachedFu(
      fv: fv,
      item: cache.get,
      get: (collection, key) => collection[key],
      keys: (collecion) => collecion.keys,
      sortedKeys: (collecion) => collecion.keys.sorted(compareNaturalOrder),
      disposers: disposers,
    );
  }

  CachedFu({
    required this.fv,
    required F Function(K key) item,
    required T? Function(C collection, K key) get,
    required Iterable<K> Function(C collecion) keys,
    required Iterable<K> Function(C collecion) sortedKeys,
    required DspReg? disposers,
  })  : _item = item,
        _get = get,
        _keys = keys,
        _sortedKeys = sortedKeys,
        _disposers = disposers;
}
