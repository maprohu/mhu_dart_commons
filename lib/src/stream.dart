import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:rxdart/rxdart.dart';

import 'dispose.dart';
import 'freezed.dart';
import 'functions.dart';

part 'stream.freezed.dart';

extension MhuStreamX<T> on Stream<T> {
  Future<void> asyncForEach(FutureOr<void> Function(T value) action) async {
    await for (final value in this) {
      await action(value);
    }
  }

  StreamSubscription<T> asyncListen(
    Future<void> Function(T event) onData,
  ) {
    return asyncMap(
      (value) async {
        await onData(value);
        return value;
      },
    ).listen(ignore1);
  }
}

extension MhuStreamOfIterablesX<T> on Stream<Iterable<T>> {
  Stream<T> get flatten => expand(identity);
}

extension StreamSubscriptionX<T> on StreamSubscription<T> {
  void cancelBy(DspReg? disposers) {
    disposers?.add(cancel);
  }
}

@freezed
class SetDiff<T> with _$SetDiff<T> {
  const factory SetDiff({
    required ISet<T> added,
    required ISet<T> removed,
  }) = _SetDiff;

  factory SetDiff.fromISets({
    required ISet<T> before,
    required ISet<T> after,
  }) {
    return SetDiff(
      added: after.removeAll(before),
      removed: before.removeAll(after),
    );
  }
}

extension StreamOfISetX<T> on Stream<ISet<T>> {
  Stream<SetDiff<T>> get diffs {
    return Rx.concat([
      Stream.value(ISet<T>()),
      this,
    ]).bufferCount(2, 1).map(
      (pair) {
        switch (pair) {
          case [final before, final after]:
            return SetDiff.fromISets(
              before: before,
              after: after,
            );
          case [final last]:
            return SetDiff(
              added: ISet(),
              removed: last,
            );
          default:
            throw pair; // should not happen
        }
      },
    );
  }

  void processDiffs({
    required Future<void> Function(T item) added,
    required Future<void> Function(T item) removed,
    required DspReg disposers,
  }) async {
    final listening = diffs.asyncListen((diff) async {
      await Future.wait([
        ...diff.added.map(added),
        ...diff.removed.map(removed),
      ]);
    });

    disposers.add(listening.cancel);
  }
}
