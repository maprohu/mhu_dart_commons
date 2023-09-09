import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:rxdart/rxdart.dart';

import 'dispose.dart';
import 'freezed.dart';
import 'functions.dart';

import 'stream.dart' as $lib;
// part 'stream.g.has.dart';
part 'stream.g.dart';
// part 'stream.freezed.dart';


part 'stream.freezed.dart';

typedef BeforeAfter<T> = ({
  T before,
  T after,
});

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

  Stream<BeforeAfter<T>> beforeAfter({
    required T first,
  }) {
    return Rx.concat([
      Stream.value(first),
      this,
    ]).bufferCount(2).map((window) {
      final [before, after] = window;

      return (
        before: before,
        after: after,
      );
    });
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

Stream<T> streamTail<T>({
  @ext required Stream<T> stream,
}) {
  return stream.skip(1);
}
