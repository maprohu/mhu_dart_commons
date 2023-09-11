part of '../isar.dart';

@Compose()
abstract class IsarCtx implements HasIsar {}

@Compose()
abstract class IsarCollectionCtx<R> implements IsarCtx, IsarCollectionBits<R> {}

@Compose()
abstract class IsarRecordCtx<R> implements IsarCollectionCtx<R>, HasIsarId {}

IsarCollectionCtx<R> isarCollectionCtx<R>({
  @ext required IsarCollectionBits<R> collectionBits,
  @ext required Isar isar,
}) {
  return ComposedIsarCollectionCtx.isarCollectionBits(
    isarCollectionBits: collectionBits,
    isar: isar,
  );
}

IsarCollection<R> getIsarCollectionCtx<R>({
  @ext required IsarCollectionCtx<R> collectionCtx,
}) {
  return collectionCtx.getIsarCollection(
    collectionCtx.isar,
  );
}

void isarRecordWriteId<R>({
  @ext required IsarRecordCtx<R> recordCtx,
  @ext required R record,
}) {
  recordCtx.isarIdAttribute.writeAttribute(
    record,
    recordCtx.isarId,
  );
}

IsarRecordCtx<R> isarRecordCtx<R>({
  @ext required IsarCollectionCtx<R> collectionCtx,
  required IsarId isarId,
}) {
  return ComposedIsarRecordCtx.isarCollectionCtx(
    isarCollectionCtx: collectionCtx,
    isarId: isarId,
  );
}

Future<R?> loadIsarRecordCtx<R>({
  @ext required IsarRecordCtx<R> recordCtx,
}) {
  return recordCtx.getIsarCollectionCtx().get(
        recordCtx.isarId,
      );
}
