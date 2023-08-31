import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';

// ignore: unused_import
import 'package:mhu_dart_commons/src/kt.dart';

import 'map.dart' as $lib;

// part 'map.g.has.dart';
part 'map.g.dart';

extension MhuMapOfRequiredValueX<K, V extends Object> on Map<K, V> {
  void putOrRemove(K key, V? value) {
    if (value != null) {
      this[key] = value;
    } else {
      remove(key);
    }
  }

  V getOrThrow(K key) => this[key] ?? (throw ('key not found', key));

  V? get(K key) => this[key];

  MapEntry<K, V>? entry(K key) => get(key)?.asEntryValue(key);
}

extension MhuMapIterableX<T> on Iterable<T> {
  IMap<K, T> uniqueIndexBy<K>(K Function(T value) key) =>
      IMap({for (final value in this) key(value): value});
}

extension MhuMapEntryAnyX<T> on T {
  MapEntry<K, T> asEntryValue<K>(K key) => MapEntry(key, this);
}

Map<K, V> entriesToMap<K, V>({
  @ext required Iterable<MapEntry<K, V>> entries,
}) {
  return Map.fromEntries(entries);
}

MapEntry<K, V> valueToMapEntry<K, V>({
  @ext required V value,
  required K key,
}) {
  return MapEntry(key, value);
}
