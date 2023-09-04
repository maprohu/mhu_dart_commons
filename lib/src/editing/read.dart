part of '../editing.dart';

extension HasReadValueOptX<T> on HasReadValue<T?> {
  ReadValue<V?> readAttribute<V>(
    HasReadAttribute<T, V> hasReadAttribute,
  ) {
    return () {
      final value = readValue();
      if (value == null) {
        return null;
      }
      return hasReadAttribute.readAttribute(value);
    };
  }

  ReadValue<V?> readAttributeNullable<V>(
    HasReadAttribute<T, V?> hasReadAttribute,
  ) {
    return () {
      final value = readValue();
      if (value == null) {
        return null;
      }
      return hasReadAttribute.readAttribute(value);
    };
  }
}

HasReadValue<V> mapReadValue<T, V>({
  @ext required HasReadValue<T> readValue,
  required HasReadAttribute<T, V> readAttribute,
}) {
  return ComposedReadValue(
    readValue: () => readAttribute.readAttribute(
      readValue.readValue(),
    ),
  );
}
