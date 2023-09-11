part of '../isar.dart';

mixin BlobRecord implements IsarIdRecord {
  late List<byte> blob;
}

Lift<R, Bytes> blobRecordBytesLift<R extends BlobRecord>({
  @ext required CreateValue<R> createRecord,
}) {
  return ComposedLift<R, Bytes>(
    higher: (low) => low.blob,
    lower: (high) => createRecord()..blob = high,
  );
}

