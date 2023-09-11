@HasOf<Isar>()
library;

import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'package:isar/isar.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/src/kt.dart';
import 'package:mhu_dart_commons/src/stream.dart';
import 'package:protobuf/protobuf.dart';
import 'package:rxdart/rxdart.dart';

import 'async.dart';
import 'attribute.dart';
import 'bidi.dart';
import 'binary.dart';
import 'dispose.dart';
import 'editing.dart';
import 'freezed.dart';
import 'frp.dart';
import 'functions.dart';
import 'late.dart';
import 'lift.dart';
import 'property.dart';

export 'isar_gen.dart' hide Isar;

import 'isar.dart' as $lib;
import 'singleton.dart';
import 'watch.dart';

part 'isar.g.dart';

part 'isar.freezed.dart';

part 'isar.g.has.dart';

part 'isar/context.dart';

part 'isar/write_only.dart';

part 'isar/blob.dart';

part 'isar/collection.dart';

@Has()
typedef IsarId = Id;

extension IsarDisposeX on Isar {
  Future<bool> dispose() => close(deleteFromDisk: false);

  Disposable toDisposable() => DspImpl()..add(dispose);
}

abstract class IsarIdRecord {
  Id? get id;

  set id(Id? id);
}

IsarIdAttribute<R> hasIsarIdAttribute<R extends IsarIdRecord>() =>
    ComposedReadWriteAttribute(
      readAttribute: (object) => object.id,
      writeAttribute: (object, attribute) => object.id = attribute,
    );

abstract class IsarManualId implements IsarIdRecord {
  @override
  Id? id = Isar.autoIncrement;
}

mixin IsarIdRecordMixin implements IsarIdRecord {
  @override
  Id? id;
}

abstract base class SingletonRecord with BlobRecord, IsarIdRecordMixin {}

typedef IsarSingletonCollection<R extends SingletonRecord> = IsarCollection<R>;

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
}

Stream<IList<Id>> Function(int size) isarTakeIds<R extends IsarIdRecord>({
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

Stream<R> Function(Id key) isarWatchItem<R extends IsarIdRecord>({
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

  Future<Fw<M?>> protoRecordFwNullable({
    required int id,
    required DspReg disposers,
  }) async {
    return this.collection.recordFwNullable(
          id: id,
          bidi: BiDi(
            forward: (record) => record.proto$.value,
            backward: (message) => createRecord()..proto$.value = message,
          ),
          disposers: disposers,
        );
  }

  Future<Fw<M?>> protoRecordFwNullableWriteOnly({
    required int id,
    required DspReg disposers,
  }) async {
    return this.collection.recordFwNullableWriteOnly(
          id: id,
          bidi: BiDi(
            forward: (record) => record.proto$.value,
            backward: (message) => createRecord()..proto$.value = message,
          ),
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

extension IsarCollectionX<R extends IsarIdRecord> on IsarCollection<R> {
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

  Future<Fw<T?>> recordFwNullable<T>({
    required int id,
    required BiDi<R, T> bidi,
    required DspReg disposers,
  }) async {
    T? parse(R? record) => record?.let(bidi.forward);

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

    final updates = StreamController<T?>()..closeBy(disposers);

    updates.stream.asyncForEach((value) async {
      await isar.writeTxn(() async {
        if (value == null) {
          await delete(id);
        } else {
          await put(
            bidi.backward(value)..id = id,
          );
        }
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

  Future<Fw<T?>> recordFwNullableWriteOnly<T extends Object>({
    required int id,
    required BiDi<R, T> bidi,
    required DspReg disposers,
  }) async {
    T? parse(R? record) => record?.let(bidi.forward);

    final result = disposers.fw(
      parse(
        await get(id),
      ),
    );

    final writer = LatestExecutor<T?>(
      disposers: disposers,
      process: (value) async {
        await isar.writeTxn(() async {
          if (value == null) {
            await delete(id);
          } else {
            await put(
              bidi.backward(value)..id = id,
            );
          }
        });
      },
    );

    return Fw.fromFr(
      fr: result,
      set: (value) {
        writer.submit(value);
        result.set(value);
      },
    );
  }
}

extension CustomIsarCollectionX<R> on IsarCollection<R> {
  Future<Fw<T?>> customIdRecordFw<T extends Object>({
    required R Function() createRecord,
    required int Function(R record) getRecordId,
    required void Function(R record, T value) setRecordValue,
    required T Function(R record) getRecordValue,
    required DspReg disposers,
  }) async {
    T? parse(R? record) => record?.let(getRecordValue);
    final resultDsp = DspImpl();
    final recordId = getRecordId(createRecord());
    final result = resultDsp.fw(
      parse(await get(recordId)),
    );

    final listening = watchObject(
      recordId,
      fireImmediately: true,
    ).map(parse).listen(result.set);

    final updates = StreamController<T?>()..closeBy(disposers);

    updates.stream.asyncForEach((value) async {
      await isar.writeTxn(() async {
        if (value == null) {
          await delete(recordId);
        } else {
          await put(
            createRecord().also(
              (r) => setRecordValue(r, value),
            ),
          );
        }
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

// Future<WatchMessage<T>> createIsarSingletonProtoWriteOnlyWatch<
//         T extends GeneratedMessage, R extends SingletonRecord>({
//   @Ext() required IsarSingletonCollection<R> isarSingletonCollection,
//   required CreateValue<R> createRecord,
//   required int id,
//   required T Function() create,
//   T? defaultValue,
//   required DspReg disposers,
// }) =>
//     createIsarSingletonWriteOnlyWatch(
//       isarSingletonCollection: isarSingletonCollection,
//       createRecord: createRecord,
//       id: id,
//       lift: create.createBinaryProtoLift(),
//       defaultValue: defaultValue ?? create()
//         ..freeze(),
//       disposers: disposers,
//     );

// Future<WatchMessage<T>> createIsarSingletonWriteOnlyWatch<T extends Object,
//     R extends SingletonRecord>({
//   @Ext() required IsarSingletonCollection<R> isarSingletonCollection,
//   required CreateValue<R> createRecord,
//   required int id,
//   required Lift<List<byte>, T> lift,
//   required T defaultValue,
//   required DspReg disposers,
// }) async {
//   return isarSingletonCollection.createIsarBlobRecordWriteOnlyWatch(
//     id: id,
//     createRecord: createRecord,
//     lift: lift,
//     defaultValue: defaultValue,
//     disposers: disposers,
//   );
// }

@Has()
typedef IsarSingletonId = Id;

// @Has()
// typedef IsarSingletonIdHolder = LateFinal<IsarSingletonId>;

@Has()
typedef CreateIsarSingletonWatch<T extends Object> = Future<WatchMessage<T>>
    Function({
  required Isar isar,
  required IsarSingletonId isarSingletonId,
  required DspReg disposers,
});

@Compose()
abstract class IsarSingletonWatchFactory<T extends Object>
    implements
        HasSingletonKeyHolder<IsarSingletonId>,
        HasCreateIsarSingletonWatch<T> {}

Future<WatchProto<M>> produceIsarSingletonWatch<M extends GeneratedMessage>({
  @Ext() required IsarSingletonWatchFactory<M> factory,
  required Isar isar,
  required DspReg disposers,
}) {
  assert(M != GeneratedMessage);
  return factory.createIsarSingletonWatch(
    isar: isar,
    isarSingletonId: factory.getSingletonKey(),
    disposers: disposers,
  );
}

typedef IsarSingletonFwFactories<T extends Object>
    = Singletons<IsarSingletonId, IsarSingletonWatchFactory<T>>;

IsarSingletonFwFactories<T> createIsarSingletonWatchFactories<T extends Object>(
  Map<IsarSingletonId, IsarSingletonWatchFactory<T>> singletonsByKey,
) {
  return Singletons.holder(singletonsByKey);
}

IsarSingletonWatchFactory<M> createIsarSingletonProtoWriteOnlyWatchFactory<
    M extends GeneratedMessage, R extends SingletonRecord>({
  @Ext() required CreateValue<M> createValue,
  required IsarCollectionBits<R> collectionBits,
  DefaultValue<M>? defaultValue,
}) {
  final lift = collectionBits.isarBlobCollectionBytesLift().liftComposition$(
        createValue.createBinaryProtoLift(),
      );

  assert(M != GeneratedMessage);
  return ComposedIsarSingletonWatchFactory<M>(
    singletonKeyHolder: SingletonKeyHolder(),
    createIsarSingletonWatch: ({
      required disposers,
      required isar,
      required isarSingletonId,
    }) async {
      final recordCtx = isarCollectionCtx(
        collectionBits: collectionBits,
        isar: isar,
      ).isarRecordCtx(
        isarId: isarSingletonId,
      );
      final initialRecord = await recordCtx.loadIsarRecordCtx();
      final initialValue = initialRecord?.let(lift.higher);



      return watchVar(initialValue).isarWatchMessagePutLatest(
        recordCtx: recordCtx,
        lower: lift.lower,
        putFirst: false,
        disposers: disposers,
        callDefaultMessage: (defaultValue ?? createValue()
              ..freeze())
            .constantCall(),
      );
    },
  );
}
