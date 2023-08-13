import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';

part 'editing.g.has.dart';

part 'editing.g.compose.dart';

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
abstract class ScalarValue<T>
    implements ReadWatchValue<T?>, HasWriteValue<T?>, ReadWriteValue<T?> {}

@Compose()
abstract class MapValue<K, V>
    implements ReadWatchValue<Map<K, V>?>, HasUpdateValue<Map<K, V>> {}

@Compose()
abstract class ListValue<E>
    implements ReadWatchValue<List<E>?>, HasUpdateValue<List<E>> {}

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
