import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'package:isar/isar.dart';
import 'package:mhu_dart_commons/src/kt.dart';
import 'package:mhu_dart_commons/src/stream.dart';
import 'package:protobuf/protobuf.dart';
import 'package:rxdart/rxdart.dart';

import 'bidi.dart';
import 'dispose.dart';
import 'freezed.dart';
import 'frp.dart';
import 'property.dart';

part 'isar.g.dart';

part 'isar.freezed.dart';

extension IsarDisposeX on Isar {
  Future<bool> dispose() => close(deleteFromDisk: false);

  Disposable toDisposable() => DspImpl()..add(dispose);
}

abstract class HasIsarId {
  Id? get id;

  set id(Id? id);
}

abstract class BlobRecord implements HasIsarId {
  late List<byte> blob;
}

abstract class IsarManualId implements HasIsarId {
  @override
  Id? id = Isar.autoIncrement;
}

mixin IsarAutoId implements HasIsarId {
  @override
  Id? id;
}

@collection
class SingletonRecord extends BlobRecord with IsarAutoId {}

@collection
class SequenceRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String sequenceName;

  late int latestValue;
}

extension FrpIsarX on Isar {
  Future<int> getSequenceNextTxn(String sequenceName) async {
    final record = await sequenceRecords.getBySequenceName(sequenceName);

    if (record == null) {
      const firstValue = 1;
      await sequenceRecords.put(
        SequenceRecord()
          ..sequenceName = sequenceName
          ..latestValue = firstValue,
      );
      return firstValue;
    }

    final nextValue = record.latestValue + 1;

    await sequenceRecords.put(
      SequenceRecord()
        ..id = record.id
        ..sequenceName = sequenceName
        ..latestValue = nextValue,
    );

    return nextValue;
  }

  Future<Fw<T>> singletonFw<T>({
    required int id,
    required BiDi<List<byte>, T> bidi,
    required T defaultValue,
    required DspReg disposers,
  }) async {
    return singletonRecords.blobRecordFw(
      id: id,
      createRecord: SingletonRecord.new,
      bidi: bidi,
      defaultValue: defaultValue,
      disposers: disposers,
    );

    //
    // T parse(SingletonRecord? record) =>
    //     record?.blob.let(bidi.forward) ?? defaultValue;
    //
    // final result = fw(
    //   parse(
    //     await singletonRecords.get(id),
    //   ),
    // );
    //
    // final listening = singletonRecords
    //     .watchObject(
    //   id,
    //   fireImmediately: true,
    // )
    //     .map(parse)
    //     .listen(result.set);
    //
    // final updates = StreamController<T>()
    //   ..closeBy(disposers);
    //
    // updates.stream.asyncForEach((value) async {
    //   await writeTxn(() async {
    //     await singletonRecords.put(
    //       SingletonRecord()
    //         ..id = id
    //         ..blob = bidi.backward(value),
    //     );
    //   });
    // }).awaitBy(disposers);
    //
    // disposers.add(() async {
    //   await listening.cancel();
    //   await result.dispose();
    // });
    //
    // return mk.Fwi.fromFr(
    //   fr: result,
    //   set: (value) {
    //     updates.add(value);
    //     result.set(value);
    //   },
    // );
  }

  Future<Fw<T>> singletonFwProto<T extends GeneratedMessage>({
    required int id,
    required T Function() create,
    T? defaultValue,
    required DspReg disposers,
  }) =>
      singletonFw(
        id: id,
        bidi: BiDi.proto(create),
        defaultValue: defaultValue ?? create()
          ..freeze(),
        disposers: disposers,
      );
}

Stream<IList<Id>> Function(int size) isarTakeIds<R extends HasIsarId>({
  required IsarCollection<R> collection,
  required QueryBuilder<R, R, QAfterWhere> Function(
          QueryBuilder<R, R, QWhere> query)
      sortProp,
  Sort sortOrder = Sort.desc,
}) {
  QueryBuilder<R, int, QQueryOperations> idProperty(
      QueryBuilder<R, R, QQueryProperty> query) {
    // ignore: invalid_use_of_protected_member
    return QueryBuilder.apply(query, (query) {
      return query.addPropertyName(r'id');
    });
  }

  return (size) => collection
      .watchLazy(fireImmediately: true)
      .asyncMap(
        (_) => collection
            .where(sort: sortOrder)
            .let(sortProp)
            .limit(size)
            .let(idProperty)
            .findAll(),
      )
      .map(
        (e) => e.toIList(),
      );
}

Stream<R> Function(Id key) isarWatchItem<R extends HasIsarId>({
  required IsarCollection<R> collection,
}) =>
    (key) => collection.watchObject(key, fireImmediately: true).whereNotNull();

mixin ProtoRecord<M extends GeneratedMessage> implements BlobRecord {
  M createProto$();

  @ignore
  late final proto$ = RequiredProp<M>(
    get: () => createProto$()
      ..mergeFromBuffer(blob)
      ..freeze(),
    set: (message) => blob = message.writeToBuffer(),
  );
}

@freezed
class IsarCollectionWithCreateRecord<R>
    with _$IsarCollectionWithCreateRecord<R> {
  const factory IsarCollectionWithCreateRecord({
    required IsarCollection<R> collection,
    required R Function() createRecord,
  }) = _IsarCollectionWithCreateRecord;
}

extension IsarCollectionWithCreateRecordX<M extends GeneratedMessage>
    on IsarCollectionWithCreateRecord<ProtoRecord<M>> {
  Future<Fw<M>> protoRecordFw({
    required int id,
    required DspReg disposers,
  }) async {
    final record = createRecord();
    return this.collection.recordFw(
          id: id,
          bidi: BiDi(
            forward: (record) => record.proto$.value,
            backward: (message) => createRecord()..proto$.value = message,
          ),
          defaultValue: record.createProto$()..freeze(),
          disposers: disposers,
        );
  }
}

extension ProtoRecordIsarCollectionX<R> on IsarCollection<R> {
  IsarCollectionWithCreateRecord<R> withCreateRecord(
    R Function() createRecord,
  ) =>
      IsarCollectionWithCreateRecord(
        collection: this,
        createRecord: createRecord,
      );
}

extension BlobRecordIsarCollectionX<R extends BlobRecord> on IsarCollection<R> {
  Future<Fw<T>> blobRecordFw<T>({
    required int id,
    required R Function() createRecord,
    required BiDi<List<int>, T> bidi,
    required T defaultValue,
    required DspReg disposers,
  }) async {
    return recordFw(
      id: id,
      bidi: BiDi(
        forward: (record) => bidi.forward(record.blob),
        backward: (message) => createRecord()..blob = bidi.backward(message),
      ),
      defaultValue: defaultValue,
      disposers: disposers,
    );
  }
}

extension IsarCollectionX<R extends HasIsarId> on IsarCollection<R> {
  Future<Fw<T>> recordFw<T>({
    required int id,
    required BiDi<R, T> bidi,
    required T defaultValue,
    required DspReg disposers,
  }) async {
    T parse(R? record) => record?.let(bidi.forward) ?? defaultValue;

    final resultDsp = DspImpl();
    final result = resultDsp.fw(
      parse(
        await get(id),
      ),
    );

    final listening = watchObject(
      id,
      fireImmediately: true,
    ).map(parse).listen(result.set);

    final updates = StreamController<T>()..closeBy(disposers);

    updates.stream.asyncForEach((value) async {
      await isar.writeTxn(() async {
        await put(
          bidi.backward(value)..id = id,
        );
      });
    }).awaitBy(disposers);

    disposers.add(() async {
      await listening.cancel();
      await resultDsp.dispose();
    });

    return Fw.fromFr(
      fr: result,
      set: (value) {
        updates.add(value);
        result.set(value);
      },
    );
  }
}
