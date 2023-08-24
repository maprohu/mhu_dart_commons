import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';

part 'editing.g.has.dart';

part 'editing.g.dart';

@Has()
typedef DefaultValue<T> = T;

@Has()
typedef DefaultValueOpt<T> = T?;

@Has()
typedef CreateValue<T> = T Function();

@Has()
typedef ReadValue<T> = T Function();

@Has()
typedef WriteValue<T> = void Function(T value);

@Has()
typedef WatchValue<T> = T Function();

@Has()
@Compose()
typedef UpdateValue<T> = void Function(
  void Function(T value) updates,
);

@Has()
typedef DefaultMessage<O> = O;

@Has()
typedef RebuildMessage<O> = O Function(
  O message,
  void Function(O message) updates,
);

@Compose()
abstract class MessageUpdateBits<O>
    implements HasDefaultMessage<O>, HasRebuildMessage<O> {}

@Compose()
abstract class ReadWatchValue<T> implements HasReadValue<T>, HasWatchValue<T> {}

abstract class ReadWriteValue<T> implements HasReadValue<T>, HasWriteValue<T> {}

@Compose()
abstract class MutableValue<T>
    implements ReadWatchValue<T?>, HasUpdateValue<T> {}

@Compose()
abstract class ScalarValue<T>
    implements ReadWatchValue<T?>, HasWriteValue<T?>, ReadWriteValue<T?> {}

@Compose()
abstract class MapValue<K, V>
    implements
        ReadWatchValue<Map<K, V>?>,
        HasUpdateValue<Map<K, V>>,
        MutableValue<Map<K, V>> {}

@Compose()
abstract class ListValue<E>
    implements
        ReadWatchValue<List<E>?>,
        HasUpdateValue<List<E>>,
        MutableValue<List<E>> {}

extension HasReadValueX<T> on HasReadValue<T?> {
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

extension HasWatchValueX<T> on HasWatchValue<T?> {
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

extension ReadWriteValueX<T> on ReadWriteValue<T?> {
  UpdateValue<T> updateMessage(
    MessageUpdateBits<T> messageUpdateBits,
  ) {
    return (updates) {
      final currentValue = readValue() ?? messageUpdateBits.defaultMessage;

      writeValue(
        messageUpdateBits.rebuildMessage(
          currentValue,
          updates,
        ),
      );
    };
  }

  WriteValue<V?> writeAttribute<V>({
    required MessageUpdateBits<T> messageUpdateBits,
    required ScalarAttribute<T, V> scalarAttribute,
  }) {
    return ComposedUpdateValue(
      updateValue: updateMessage(
        messageUpdateBits,
      ),
    ).writeAttribute(
      scalarAttribute,
    );
  }

  HasUpdateValue<V> updateAttribute<V>({
    required MessageUpdateBits<T> messageUpdateBits,
    required HasEnsureAttribute<T, V> hasEnsureAttribute,
  }) {
    return ComposedUpdateValue(
      updateValue: updateMessage(
        messageUpdateBits,
      ),
    ).updateAttribute(
      hasEnsureAttribute,
    );
  }
}

extension HasUpdateValueX<T> on HasUpdateValue<T> {
  WriteValue<V?> writeAttribute<V>(
    ScalarAttribute<T, V> scalarAttribute,
  ) {
    return (value) {
      updateValue(
        (message) {
          if (value == null) {
            scalarAttribute.clearAttribute(message);
          } else {
            scalarAttribute.writeAttribute(message, value);
          }
        },
      );
    };
  }

  HasUpdateValue<V> updateAttribute<V>(
    HasEnsureAttribute<T, V> hasEnsureAttribute,
  ) {
    return ComposedUpdateValue(
      updateValue: (updates) {
        updateValue(
          (value) {
            updates(
              hasEnsureAttribute.ensureAttribute(
                value,
              ),
            );
          },
        );
      },
    );
  }
}

extension MutableValueX<T> on MutableValue<T> {
  MutableValue<V> mutableAttribute<V>(
    MutableAttribute<T, V> mutableAttribute,
  ) {
    return ComposedMutableValue.readWatchValue(
      readWatchValue: readWatchAttribute(mutableAttribute),
      updateValue: updateAttribute(mutableAttribute).updateValue,
    );
  }

  ScalarValue<V> scalarAttribute<V>(
    ScalarAttribute<T, V> scalarAttribute,
  ) {
    return ComposedScalarValue.readWatchValue(
      readWatchValue: readWatchAttribute(
        scalarAttribute,
      ),
      writeValue: writeAttribute(
        scalarAttribute,
      ),
    );
  }
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

extension ScalarValueX<T> on ScalarValue<T> {
  ScalarValue<V> scalarAttribute<V>({
    required MessageUpdateBits<T> messageUpdateBits,
    required ScalarAttribute<T, V> scalarAttribute,
  }) {
    return ComposedScalarValue.readWatchValue(
      readWatchValue: readWatchAttribute(
        scalarAttribute,
      ),
      writeValue: writeAttribute(
        messageUpdateBits: messageUpdateBits,
        scalarAttribute: scalarAttribute,
      ),
    );
  }

  MapValue<K, V> mapAttribute<K, V>({
    required MessageUpdateBits<T> messageUpdateBits,
    required HasReadAttribute<T, Map<K, V>> hasReadAttribute,
  }) {
    return ComposedMapValue.readWatchValue(
      readWatchValue: readWatchAttribute(
        hasReadAttribute,
      ),
      updateValue: updateAttribute(
        messageUpdateBits: messageUpdateBits,
        hasEnsureAttribute: ComposedEnsureAttribute(
          ensureAttribute: hasReadAttribute.readAttribute,
        ),
      ).updateValue,
    );
    // updateValue: update
  }
}

extension MapValueX<K, V> on MapValue<K, V> {
  static HasReadAttribute<Map<K, V>, V?> readMapItemAttribute<K, V>(K key) {
    return ComposedReadAttribute(
      readAttribute: (map) {
        return map[key];
      },
    );
  }

  ScalarValue<V> itemValue(K key) {
    return ComposedScalarValue.readWatchValue(
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

extension EditingFwX<T> on Fw<T> {
  ScalarValue<T> get toScalarValue {
    return ComposedScalarValue(
      readValue: read,
      watchValue: watch,
      writeValue: (value) {
        if (value == null) {
          throw "set null not supported";
        }

        set(value);
      },
    );
  }
}

extension EditingFuX<T> on Fu<T> {
  MutableValue<T> get toMutableValue {
    return ComposedMutableValue(
      readValue: read,
      watchValue: watch,
      updateValue: update,
    );
  }
}
