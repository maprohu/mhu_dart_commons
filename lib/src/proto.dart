import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:protobuf/protobuf.dart';

import 'string.dart';
import 'kt.dart';

part 'proto.freezed.dart';

extension MhuBaseGeneratedMessageX<M extends GeneratedMessage> on M {
  M deepRebuild(void Function(M message) updates) {
    return deepCopy().also(updates)..freeze();
  }

  M selectRebuild<S>({
    required S Function(M message) select,
    required void Function(S selected) updates,
  }) {
    return deepRebuild(
      (message) => updates(
        select(message),
      ),
    );
  }
}

extension MhuProtoEnumX<T extends ProtobufEnum> on T {
  String get label => name.camelCaseToLabel;
}

@freezed
sealed class PbMapKey with _$PbMapKey {
  const factory PbMapKey.string(String value) = PbStringMapKey;

  const factory PbMapKey.int(int value) = PbIntMapKey;

  static const defaultString = PbStringMapKey('');
  static const defaultInt = PbIntMapKey(0);
}

extension PbMapKeyX on PbMapKey {
  Object get value => switch (this) {
        PbIntMapKey(:final value) => value,
        PbStringMapKey(:final value) => value,
      };

  PbMapKey Function(Object value) get withValue => switch (this) {
        PbIntMapKey() => (value) => PbIntMapKey(value as int),
        PbStringMapKey() => (value) => PbStringMapKey(value as String),
      };
}

typedef StringMapEntry<T> = MapEntry<String, T>;
typedef IntMapEntry<T> = MapEntry<int, T>;
