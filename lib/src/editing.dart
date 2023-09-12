import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';
import 'package:protobuf/protobuf.dart';

import 'editing.dart' as $lib;

part 'editing.g.has.dart';

part 'editing.g.dart';

part 'editing/read.dart';

part 'editing/write.dart';

part 'editing/update.dart';

part 'editing/mutable.dart';

part 'editing/watch.dart';

part 'editing/map.dart';

part 'editing/proto.dart';

part 'editing/async.dart';

part 'editing/reload.dart';

// part 'editing.freezed.dart';

@Has()
typedef DefaultValue<T> = T;

@Has()
typedef DefaultValueOpt<T> = T?;

@Has()
typedef CreateValue<T> = T Function();

@Has()
@Compose()
typedef ReadValue<T> = T Function();

@Has()
@Compose()
typedef WriteValue<T> = void Function(T value);

@Has()
@Compose()
typedef WatchValue<T> = T Function();

@Has()
typedef Updates<T> = void Function(T value);

@Has()
@Compose()
typedef UpdateValue<T> = void Function(
  Updates<T> updates,
);

typedef MutableUpdates<T> = void Function(T object);

@Has()
typedef DefaultMessage<O> = O;

@Has()
typedef RebuildMessage<O> = O Function(
  O message,
  void Function(O message) updates,
);

// @Compose()
// abstract class MessageRebuildBits<O>
//     implements HasCallDefaultMessage<O>, HasRebuildMessage<O> {}

@Compose()
abstract class ReadWatchValue<T> implements HasReadValue<T>, HasWatchValue<T> {}

@Compose()
abstract class ReadWriteValue<T> implements HasReadValue<T>, HasWriteValue<T> {}

@Compose()
abstract class MutableValue<T>
    implements ReadWatchValue<T?>, HasUpdateValue<T> {}

@Compose()
abstract class SingleValue<T>
    implements ReadWatchValue<T?>, HasWriteValue<T?>, ReadWriteValue<T?> {}

@Compose()
@Has()
abstract class MessageValue<T>
    implements SingleValue<T>, HasCallDefaultMessage<T> {}

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

// extension EditingFwX<T> on Fw<T> {
//   SingleValue<T> get toScalarValue {
//     return ComposedSingleValue(
//       readValue: read,
//       watchValue: watch,
//       writeValue: (value) {
//         if (value == null) {
//           throw "set null not supported";
//         }
//
//         set(value);
//       },
//     );
//   }
// }

// extension EditingFuX<T> on Fu<T> {
//   MutableValue<T> get toMutableValue {
//     return ComposedMutableValue(
//       readValue: read,
//       watchValue: watch,
//       updateValue: update,
//     );
//   }
// }
