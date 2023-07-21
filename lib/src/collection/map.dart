import 'package:fast_immutable_collections/fast_immutable_collections.dart';

extension MhuMapOfRequiredValueX<K, V extends Object> on Map<K, V> {
  void putOrRemove(K key, V? value) {
    if (value != null) {
      this[key] = value;
    } else {
      remove(key);
    }
  }

  V getOrThrow(K key) {
    final value = this[key];
    if (value == null) {
      throw 'element not found: $key';
    } else {
      return value;
    }
  }

  V? get(K key) => this[key];
}

extension MhuMapIterableX<T> on Iterable<T> {
  IMap<K, T> uniqueIndexBy<K>(K Function(T value) key) =>
      IMap({for (final value in this) key(value): value});
}
