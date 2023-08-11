import 'package:collection/collection.dart' as coll;
import 'package:mhu_dart_commons/commons.dart';

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

  Iterable<(T, V)> zipWith<V>(Iterable<V> other) sync* {
    final it1 = iterator;
    final it2 = other.iterator;

    while (it1.moveNext() && it2.moveNext()) {
      yield (it1.current, it2.current);
    }
  }

  void zipForEachWith<V>(Iterable<V> other, void Function(T, V) fn) {
    final it1 = iterator;
    final it2 = other.iterator;

    while (it1.moveNext() && it2.moveNext()) {
      fn(it1.current, it2.current);
    }
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
    if (isEmpty) {
      return;
    }

    yield first;

    for (final item in tail) {
      yield separator;
      yield item;
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
