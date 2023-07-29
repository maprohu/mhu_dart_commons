import 'package:freezed_annotation/freezed_annotation.dart';
export 'package:freezed_annotation/freezed_annotation.dart' hide freezed;

const freezed = Freezed(
  when: FreezedWhenOptions.none,
  map: FreezedMapOptions.none,
);

const freezedStruct = Freezed(
  when: FreezedWhenOptions.none,
  map: FreezedMapOptions.none,
  equal: false,
);
