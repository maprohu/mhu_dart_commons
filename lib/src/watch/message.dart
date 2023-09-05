part of '../watch.dart';

WatchWrite<F?> mapWatchMessageWrite<M extends Object, F extends Object>({
  @ext required WatchMessage<M> watchMessage,
  required ReadWriteAttribute<M, F?> readWriteAttribute,
  required RebuildMessage<M> rebuildMessage,
}) {
  assert(M != Msg);
  assert(F != Object);

  return ComposedWatchWrite.watchRead(
    watchRead: watchMessage.mapWatchRead(
      readAttribute: readWriteAttribute.readOptAttribute(),
    ),
    writeValue: watchMessage
        .watchMessageWriteValue(
          rebuildMessage: rebuildMessage,
          writeAttribute: readWriteAttribute,
        )
        .writeValue,
  );
}

HasUpdateValue<M> watchMessageUpdate<M extends Object>({
  @ext required WatchMessage<M> watchMessage,
  required RebuildMessage<M> rebuildMessage,
}) {
  return ComposedUpdateValue(
    updateValue: (updates) {
      final msg = watchMessage.readValue() ?? watchMessage.callDefaultMessage();

      watchMessage.writeValue(
        rebuildMessage(
          msg,
          updates,
        ),
      );
    },
  );
}

HasWriteValue<F> watchMessageWriteValue<M extends Object, F>({
  @ext required WatchMessage<M> watchMessage,
  required HasWriteAttribute<M, F> writeAttribute,
  required RebuildMessage<M> rebuildMessage,
}) {
  final updateValue = watchMessage.watchMessageUpdate(
    rebuildMessage: rebuildMessage,
  );

  return ComposedWriteValue(
    writeValue: (value) {
      updateValue.updateValue(
        (msg) {
          writeAttribute.writeAttribute(
            msg,
            value,
          );
        },
      );
    },
  );
}

WatchMessage<F> mapWatchMessageMessage<M extends Object, F extends Object>({
  @ext required WatchMessage<M> watchMessage,
  required RebuildMessage<M> rebuildMessage,
  required ReadWriteAttribute<M, F?> readWriteAttribute,
  required DefaultMessage<F> defaultMessage,
}) {
  assert(M != Object);
  assert(F != Object);
  return ComposedWatchMessage.watchRead(
    watchRead: watchMessage.mapWatchRead(
      readAttribute: readWriteAttribute.readOptAttribute(),
    ),
    callDefaultMessage: () => defaultMessage,
    writeValue: watchMessage
        .watchMessageWriteValue(
          writeAttribute: readWriteAttribute,
          rebuildMessage: rebuildMessage,
        )
        .writeValue,
  );
}

M readOrDefaultMessage<M extends Object>({
  @ext required WatchMessage<M> watchMessage,
}) {
  return watchMessage.readValue() ?? watchMessage.callDefaultMessage();
}

M watchOrDefaultMessage<M extends Object>({
  @ext required WatchMessage<M> watchMessage,
}) {
  return watchMessage.watchValue() ?? watchMessage.callDefaultMessage();
}

WatchMessage<M> watchWriteMessage<M extends Object>({
  @ext required WatchWrite<M> watchWrite,
  required CallDefaultMessage<M> getDefault,
}) {
  return ComposedWatchMessage.watchWrite(
    watchWrite: watchWrite,
    callDefaultMessage: getDefault,
  );
}
