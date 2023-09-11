part of '../isar.dart';

@Has()
typedef GetIsarCollection<R> = IsarCollection<R> Function(Isar isar);

@Has()
typedef CreateIsarRecord<R> = CreateValue<R>;

@Has()
typedef IsarIdAttribute<R> = ReadWriteAttribute<R, int?>;

@Compose()
abstract class IsarCollectionBits<R>
    implements
        HasCreateIsarRecord<R>,
        HasGetIsarCollection<R>,
        HasIsarIdAttribute<R> {}

IsarCollectionBits<R> isarIdCollectionBits<R extends IsarIdRecord>({
  @ext required CreateIsarRecord<R> createIsarRecord,
}) {
  return createIsarRecord.isarCollectionBits(
    isarIdAttribute: hasIsarIdAttribute(),
  );
}

IsarCollectionBits<R> isarCollectionBits<R>({
  @ext required CreateIsarRecord<R> createIsarRecord,
  required IsarIdAttribute<R> isarIdAttribute,
}) {
  return ComposedIsarCollectionBits(
    createIsarRecord: createIsarRecord,
    getIsarCollection: (isar) => isar.collection<R>(),
    isarIdAttribute: isarIdAttribute,
  );
}

Lift<R, Bytes> isarBlobCollectionBytesLift<R extends BlobRecord>({
  @ext required IsarCollectionBits<R> collectionBits,
}) {
  return collectionBits.createIsarRecord.blobRecordBytesLift();
}
