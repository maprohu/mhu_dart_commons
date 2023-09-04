part of '../editing.dart';

extension HasWatchValueOptX<T> on HasWatchValue<T?> {
  WatchValue<V?> watchAttribute<V>(
    HasReadAttribute<T, V> hasReadAttribute,
  ) {
    return () {
      final value = watchValue();
      if (value == null) {
        return null;
      }
      return hasReadAttribute.readAttribute(value);
    };
  }

  WatchValue<V?> watchAttributeNullable<V>(
    HasReadAttribute<T, V?> hasReadAttribute,
  ) {
    return () {
      final value = watchValue();
      if (value == null) {
        return null;
      }
      return hasReadAttribute.readAttribute(value);
    };
  }
}

extension HasWatchValueX<T> on HasWatchValue<T> {
  T call() => watchValue();
}

extension ReadWatchValueX<T> on ReadWatchValue<T?> {
  ReadWatchValue<V?> readWatchAttribute<V>(
    HasReadAttribute<T, V> hasReadAttribute,
  ) {
    return ComposedReadWatchValue(
      readValue: readAttribute(hasReadAttribute),
      watchValue: watchAttribute(hasReadAttribute),
    );
  }

  ReadWatchValue<V?> readWatchAttributeNullable<V>(
    HasReadAttribute<T, V?> hasReadAttribute,
  ) {
    return ComposedReadWatchValue(
      readValue: readAttributeNullable(hasReadAttribute),
      watchValue: watchAttributeNullable(hasReadAttribute),
    );
  }
}

// extension ScalarValueX<T> on SingleValue<T> {
//   SingleValue<V> scalarAttribute<V>({
//     required MessageUpdateBits<T> messageUpdateBits,
//     required ScalarAttribute<T, V> scalarAttribute,
//   }) {
//     return ComposedScalarValue.readWatchValue(
//       readWatchValue: readWatchAttribute(
//         scalarAttribute,
//       ),
//       writeValue: writeAttribute(
//         messageUpdateBits: messageUpdateBits,
//         scalarAttribute: scalarAttribute,
//       ),
//     );
//   }
//
//   MapValue<K, V> mapAttribute<K, V>({
//     required MessageUpdateBits<T> messageUpdateBits,
//     required HasReadAttribute<T, Map<K, V>> hasReadAttribute,
//   }) {
//     return ComposedMapValue.readWatchValue(
//       readWatchValue: readWatchAttribute(
//         hasReadAttribute,
//       ),
//       updateValue: updateAttribute(
//         messageUpdateBits: messageUpdateBits,
//         hasEnsureAttribute: ComposedEnsureAttribute(
//           ensureAttribute: hasReadAttribute.readAttribute,
//         ),
//       ).updateValue,
//     );
//     // updateValue: update
//   }
// }

HasWatchValue<V> mapWatchValue<T, V>({
  @ext required HasWatchValue<T> watchValue,
  required HasReadAttribute<T, V> readAttribute,
}) {
  return ComposedWatchValue(
    watchValue: () => readAttribute.readAttribute(
      watchValue(),
    ),
  );
}

ReadWatchValue<V> mapReadWatchValue<T, V>({
  @ext required ReadWatchValue<T> readWatchValue,
  required HasReadAttribute<T, V> readAttribute,
}) {
  return ComposedReadWatchValue(
    readValue: readWatchValue.mapReadValue$(readAttribute).readValue,
    watchValue: readWatchValue.mapWatchValue$(readAttribute).watchValue,
  );
}

ReadWatchValue<T> readWatchOptEnsure<T extends Object>({
  @ext required ReadWatchValue<T?> readWatchOpt,
  required T defaultValue,
}) {
  return readWatchOpt.mapReadWatchValue(
    readAttribute: ComposedReadAttribute(
      readAttribute: (object) => object ?? defaultValue,
    ),
  );
}

ReadWatchValue<T> readWatchOptRequire<T extends Object>({
  @ext required ReadWatchValue<T?> readWatchOpt,
}) {
  return readWatchOpt.mapReadWatchValue(
    readAttribute: ComposedReadAttribute(
      readAttribute: (object) =>
          object ?? (throw ['required value missing', T]),
    ),
  );
}
