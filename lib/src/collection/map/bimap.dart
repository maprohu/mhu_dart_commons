part of '../map.dart';

@Has()
typedef KeyToValue<K, V> = IMap<K, V>;

@Has()
typedef ValueToKey<K, V> = IMap<V, K>;

@Compose()
abstract class IBiMap<K, V>
    implements HasKeyToValue<K, V>, HasValueToKey<K, V> {}

IBiMap<K, V> createIBiMap<K, V>({
  @ext required Map<K, V> map,
}) {
  final keyToValue = map.toIMap();
  final valueToKey = IMap.fromIterable(
    map.entries,
    keyMapper: (e) => e.value,
    valueMapper: (e) => e.key,
  );

  assert(keyToValue.length == valueToKey.length);

  return ComposedIBiMap(
    keyToValue: keyToValue,
    valueToKey: valueToKey,
  );
}
