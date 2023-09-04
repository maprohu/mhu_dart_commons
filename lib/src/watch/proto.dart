part of '../watch.dart';

typedef WatchProto<M extends Msg> = WatchMessage<M>;

WatchWrite<F?> mapWatchProtoWrite<M extends Msg, F extends Object>({
  @ext required WatchProto<M> watchProto,
  required ReadWriteAttribute<M, F?> readWriteAttribute,
}) {
  return mapWatchMessageWrite(
    watchMessage: watchProto,
    rebuildMessage: rebuildProtoMessage,
    readWriteAttribute: readWriteAttribute,
  );
}

WatchProto<F> mapWatchProtoMessage<M extends Msg, F extends Msg>({
  @ext required WatchProto<M> watchProto,
  required ReadWriteAttribute<M, F?> readWriteAttribute,
  required HasDefaultMessage<F> defaultMessage,
}) {
  return mapWatchMessageMessage(
    watchMessage: watchProto,
    rebuildMessage: rebuildProtoMessage,
    readWriteAttribute: readWriteAttribute,
    defaultMessage: defaultMessage.defaultMessage,
  );
}

