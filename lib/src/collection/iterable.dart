import 'package:collection/collection.dart' as coll;
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';

import 'iterable.dart' as $lib;

// part 'iterable.g.has.dart';
part 'iterable.g.dart';

part 'iterable.freezed.dart';

extension MhuIterableX<T> on Iterable<T> {
  bool get allEqualOrEmpty {
    final it = iterator;
    if (!it.moveNext()) {
      return true;
    }
    return it.allEqualTo(it.current);
  }

  bool get allEqual {
    final it = iterator;
    if (!it.moveNext()) {
      throw this;
    }
    return it.allEqualTo(it.current);
  }

  bool allEqualCmp(bool Function(T a, T b) equals) {
    final it = iterator;
    if (!it.moveNext()) {
      throw this;
    }
    return it.allEqualTo(it.current, equals);
  }

  T? maxBy<V>(
    V Function(T element) property, {
    int Function(V, V)? compare,
  }) =>
      coll.maxBy(
        this,
        property,
        compare: compare,
      );

  Iterable<T> get tail => skip(1);

  List<T> distinct() => distinctBy((t) => t);

  List<T> distinctBy(dynamic Function(T e) identity) {
    final seen = <dynamic>{};
    final result = <T>[];

    for (final e in this) {
      final id = identity(e);

      if (!seen.contains(id)) {
        seen.add(id);
        result.add(e);
      }
    }

    return result;
  }

  Iterable<(T, V)> zipWith<V>(Iterable<V> other) =>
      zip2IterablesRecords(this, other);

  void zipForEachWith<V>(Iterable<V> other, void Function(T, V) fn) {
    iterableZip2ForEach(
      left: this,
      right: other,
      action: fn,
    );
  }

  Iterable<E> zipMapWith<V, E>(
    Iterable<V> other, {
    required E Function(T a, V b) mapper,
  }) sync* {
    final it1 = iterator;
    final it2 = other.iterator;

    while (it1.moveNext() && it2.moveNext()) {
      yield mapper(it1.current, it2.current);
    }
  }

  Iterable<T> separatedBy(T separator) sync* {
    final it = iterator;

    if (!it.moveNext()) {
      return;
    }

    yield it.current;

    while (it.moveNext()) {
      yield separator;
      yield it.current;
    }
  }

  ({
    List<T> positive,
    List<T> negative,
  }) partition(bool Function(T) test) {
    final positive = <T>[];
    final negative = <T>[];

    for (final item in this) {
      if (test(item)) {
        positive.add(item);
      } else {
        negative.add(item);
      }
    }

    return (
      positive: positive,
      negative: negative,
    );
  }

  Iterable<V> takeWhileNotNull<V extends Object>(
    V? Function(T e) mapper,
  ) sync* {
    for (final item in this) {
      final mapped = mapper(item);
      if (mapped == null) {
        return;
      }
      yield mapped;
    }
  }
}

bool _eq(dynamic a, dynamic b) => a == b;

extension MhuIteratorX<T> on Iterator<T> {
  bool allEqualTo(
    T first, [
    bool Function(T a, T b) eq = _eq,
  ]) {
    while (moveNext()) {
      if (!eq(current, first)) {
        return false;
      }
    }
    return true;
  }
}

extension NullabeIterableX<T> on T? {
  Iterable<T> get nullableAsIterable sync* {
    final self = this;
    if (self != null) {
      yield self;
    }
  }

  Iterable<T> finiteIterable(T? Function(T item) next) sync* {
    var item = this;
    while (item != null) {
      yield item;
      item = next(item);
    }
  }
}

extension MhuIterableNumberExtension on Iterable<num> {
  double? get averageOrNull => isEmpty ? null : average;
}

extension MhuIterableAnyX<T> on T {
  Iterable<T> get toSingleElementIterable sync* {
    yield this;
  }

  Iterable<T> get toRepeatInfinitelyIterable sync* {
    while (true) {
      yield this;
    }
  }

  Iterable<T> infiniteIterable(T Function(T item) next) sync* {
    var item = this;
    while (true) {
      yield item;
      item = next(item);
    }
  }
}

Iterable<T> infiniteSingleElementIterator<T>(T element) sync* {
  while (true) {
    yield element;
  }
}

mixin HasParent<T> {
  T? get parent;
}

extension HasParentNullableX<T extends HasParent<T>> on T? {
  Iterable<T> get childToParentIterable sync* {
    var bits = this;
    while (bits != null) {
      yield bits;
      bits = bits.parent;
    }
  }
}

extension MhuDoubleIterableX on Iterable<double> {
  bool allRoughlyEqual([double epsilon = 0.001]) =>
      allEqualCmp(createDoubleRoughlyEqual(epsilon));
}

Iterable<int> integers({int from = 0}) sync* {
  while (true) {
    yield from++;
  }
}

mixin HasNext<T> {
  T get next;
}

extension HasNextX<T extends HasNext<T>> on T {
  Iterable<T> get iterable sync* {
    var item = this;
    while (true) {
      yield item;
      item = item.next;
    }
  }
}

extension AnyIterableX<T, I extends Iterable<T>> on I {
  I orIfEmpty(I then) => isNotEmpty ? this : then;
}

Iterable<(A, B)> zip2IterablesRecords<A, B>(
  Iterable<A> iterableA,
  Iterable<B> iterableB,
) sync* {
  final it1 = iterableA.iterator;
  final it2 = iterableB.iterator;

  while (it1.moveNext() && it2.moveNext()) {
    yield (it1.current, it2.current);
  }
}

Iterable<Zip2<L, R>> zip2Iterables<L, R>(
  Iterable<L> leftIterable,
  Iterable<R> rightIterable,
) sync* {
  final leftIterator = leftIterable.iterator;
  final rightIterator = rightIterable.iterator;

  late bool hasLeft;
  late bool hasRight;

  bool moveNext() {
    hasLeft = leftIterator.moveNext();
    hasRight = rightIterator.moveNext();

    return hasLeft || hasRight;
  }

  while (moveNext()) {
    if (hasRight && hasLeft) {
      yield Zip2Both(leftIterator.current, rightIterator.current);
    } else if (hasLeft) {
      yield Zip2Left(leftIterator.current);
    } else if (hasRight) {
      yield Zip2Right(rightIterator.current);
    }
  }
}

@freezed
sealed class Zip2<L, R> with _$Zip2<L, R> {
  const factory Zip2.left(L left) = Zip2Left;

  const factory Zip2.right(R right) = Zip2Right;

  const factory Zip2.both(L left, R right) = Zip2Both;
}

extension Zip2X<L, R> on Zip2<L, R> {
  L? get leftOrNull => switch (this) {
        Zip2Left(:final left) || Zip2Both(:final left) => left,
        _ => null,
      };

  R? get rightOrNull => switch (this) {
        Zip2Right(:final right) || Zip2Both(:final right) => right,
        _ => null,
      };
}

void iterableZip2ForEach<E1, E2>({
  required Iterable<E1> left,
  required Iterable<E2> right,
  required void Function(E1 left, E2 right) action,
}) {
  final it1 = left.iterator;
  final it2 = right.iterator;

  while (it1.moveNext() && it2.moveNext()) {
    action(it1.current, it2.current);
  }
}

typedef Routed<V, E> = ({
  Iterable<E> route,
  V value,
});

List<T> iterableToUnmodifiableList<T>({
  @ext required Iterable<T> iterable,
}) {
  return List.unmodifiable(iterable);
}

Iterable<T> iterableSeparatedBy<T>({
  @ext required Iterable<T> iterable,
  required T separator,
}) {
  return iterable.separatedBy(separator);
}

Iterable<T> iterableSeparatedByNullable<T>({
  @ext required Iterable<T> iterable,
  required T? separator,
}) {
  if (separator == null) {
    return iterable;
  } else {
    return iterable.iterableSeparatedBy(
      separator: separator,
    );
  }
}
