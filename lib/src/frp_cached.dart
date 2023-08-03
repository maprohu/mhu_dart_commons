part of 'frp.dart';

class CachedFr<T, K, C, F extends Fr<T>> with HasFr<C> {
  @override
  final Fr<C> fv$;
  final F Function(K key) _item;

  CachedFr(this.fv$, this._item);

  F item(K key) => _item(key);

  static CachedFr<T, int, List<T>, F> list<T, F extends Fr<T>>({
    required Fr<List<T>> fv,
    required F Function(Fr<T> item) wrap,
    T? defaultValue,
    DspReg? disposers,
  }) {
    final cache = Cache<int, F>((index) {
      final item = fv.itemFrHot(
        index,
        defaultValue: defaultValue,
        disposers: disposers,
      );
      return wrap(item);
    });
    return CachedFr(fv, cache.get);
  }

  static CachedFr<T, K, Map<K, T>, F> map<T, K, F extends Fr<T>>({
    required Fr<Map<K, T>> fv,
    required F Function(Fr<T> item) wrap,
    T? defaultValue,
    DspReg? disposers,
  }) {
    final cache = Cache<K, F>((index) {
      final item = fv.itemFrHot(
        index,
        defaultValue: defaultValue,
        disposers: disposers,
      );
      return wrap(item);
    });
    return CachedFr(fv, cache.get);
  }
}
