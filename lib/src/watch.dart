import 'dart:async';

import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';
import 'package:mhu_dart_commons/src/pause.dart';
import 'package:protobuf/protobuf.dart';
import 'package:rxdart/rxdart.dart';

import 'context.dart';
import 'dispose.dart';
import 'editing.dart';

import 'functions.dart';
import 'watch.dart' as $lib;

part 'watch.g.has.dart';

part 'watch.g.dart';

part 'watch/impl.dart';

part 'watch/read.dart';

part 'watch/write.dart';

part 'watch/stream.dart';

part 'watch/proto.dart';

part 'watch/message.dart';

@Has()
typedef DistinctValues<T> = Call<Stream<T>>;

@Compose()
abstract class WatchRead<T>
    implements ReadWatchValue<T>, HasDistinctValues<T>, HasRunPaused {}

@Compose()
abstract class WatchWrite<T>
    implements WatchRead<T>, ReadWriteValue<T>, HasWriteValue<T> {}

@Compose()
abstract class WatchUpdate<T> implements WatchRead<T?>, MutableValue<T> {}

@Compose()
abstract class WatchMessage<T extends Object>
    implements
        WatchRead<T?>,
        WatchWrite<T?>,
        MessageValue<T> {}
