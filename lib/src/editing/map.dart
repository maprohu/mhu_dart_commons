part of '../editing.dart';

extension MapValueX<K, V> on MapValue<K, V> {
  static HasReadAttribute<Map<K, V>, V?> readMapItemAttribute<K, V>(K key) {
    return ComposedReadAttribute(
      readAttribute: (map) {
        return map[key];
      },
    );
  }

  SingleValue<V> itemValue(K key) {
    return ComposedSingleValue.readWatchValue(
      readWatchValue: readWatchAttributeNullable(
        readMapItemAttribute<K, V>(key),
      ),
      writeValue: (value) {
        updateValue(
              (map) {
            if (value == null) {
              map.remove(key);
            } else {
              map[key] = value;
            }
          },
        );
      },
    );
  }
}

