part of '../watch.dart';

typedef WatchProto<M extends Msg> = WatchMessage<M>;

WatchWrite<F?> mapWatchProtoWrite<M extends Msg, F extends Object>({
  @ext required WatchProto<M> watchProto,
  required ReadWriteAttribute<M, F?> readWriteAttribute,
}) {
  assert(M != Msg);
  assert(F != Object);
  return mapWatchMessageWrite<M, F>(
    watchMessage: watchProto,
    rebuildMessage: rebuildProtoMessage,
    readWriteAttribute: readWriteAttribute,
  );
}

WatchProto<F> mapWatchProtoMessage<M extends Msg, F extends Msg>({
  @ext required WatchProto<M> watchProto,
  required ReadWriteAttribute<M, F?> readWriteAttribute,
  required DefaultMessage<F> defaultMessage,
}) {
  assert(M != Msg);
  assert(F != Msg);
  return mapWatchMessageMessage<M, F>(
    watchMessage: watchProto,
    rebuildMessage: rebuildProtoMessage<M>,
    readWriteAttribute: readWriteAttribute,
    defaultMessage: defaultMessage,
  );
}

HasUpdateValue<M> watchProtoUpdate<M extends Msg>({
  @ext required WatchProto<M> watchProto,
}) {
  return watchProto.watchMessageUpdate(
    rebuildMessage: rebuildProtoMessage,
  );
}

void rebuildWatchProto<M extends Msg>(
  @ext WatchProto<M> watchProto,
  MutableUpdates<M> updates,
) {
  watchProto.watchProtoUpdate().updateValue(updates);
}
