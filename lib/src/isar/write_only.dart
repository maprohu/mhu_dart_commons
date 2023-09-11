part of '../isar.dart';

Drain<R> isarPutLatestRequiredDrain<R>({
  @ext required IsarRecordCtx<R> recordCtx,
  required DspReg disposers,
}) {
  final isarCollection = recordCtx.getIsarCollectionCtx();

  return LatestExecutor<R>(
    disposers: disposers,
    process: (value) async {
      await isarCollection.isar.writeTxn(() async {
        recordCtx.isarRecordWriteId$(value);
        await isarCollection.put(value);
      });
    },
  ).submit;
}

Drain<R?> isarPutLatestNullableDrain<R extends Object>({
  @ext required IsarRecordCtx<R> recordCtx,
  required DspReg disposers,
}) {
  final isarCollection = recordCtx.getIsarCollectionCtx();

  return LatestExecutor<R?>(
    disposers: disposers,
    process: (record) async {
      await isarCollection.isar.writeTxn(() async {
        if (record == null) {
          await isarCollection.delete(
            recordCtx.isarId,
          );
        } else {
          recordCtx.isarRecordWriteId(
            record: record,
          );
          await isarCollection.put(record);
        }
      });
    },
  ).submit;
}

WatchWrite<T> isarWatchWritePutLatest<R, T>({
  @ext required WatchWrite<T> watchWrite,
  @ext required IsarRecordCtx<R> recordCtx,
  required Lower<R, T> lower,
  required bool putFirst,
  required DspReg disposers,
}) {
  final drain = recordCtx
      .isarPutLatestRequiredDrain(
        disposers: disposers,
      )
      .higherDrain(
        lower: lower,
      );

  final firstValue = watchWrite.readValue();

  if (putFirst) {
    drain(firstValue);
  }

  final putDistinct = drain.distinctDrain(initial: firstValue);

  return ComposedWatchWrite.watchRead(
    watchRead: watchWrite,
    writeValue: (value) {
      putDistinct(value);
      watchWrite.writeValue(value);
    },
  );
}

WatchMessage<T> isarWatchMessagePutLatest<R extends Object, T extends Object>({
  @ext required IsarRecordCtx<R> recordCtx,
  @ext required WatchWrite<T?> watchWrite,
  required Lower<R, T> lower,
  required bool putFirst,
  required DspReg disposers,
  required CallDefaultMessage<T> callDefaultMessage,
}) {
  final drain = recordCtx
      .isarPutLatestNullableDrain(
        disposers: disposers,
      )
      .higherDrain(
        lower: lower.convertNullable(),
      );

  final firstValue = watchWrite.readValue();

  if (putFirst) {
    drain(firstValue);
  }

  final putDistinct = drain.distinctDrain(initial: firstValue);

  return ComposedWatchWrite.watchRead(
    watchRead: watchWrite,
    writeValue: (value) {
      putDistinct(value);
      watchWrite.writeValue(value);
    },
  ).watchWriteMessage(
    getDefault: callDefaultMessage,
  );
}
