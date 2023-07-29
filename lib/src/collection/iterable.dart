import 'package:collection/collection.dart' as coll;

extension MhuIterableX<T> on Iterable<T> {
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
}

extension NullabeIterableX<T> on T? {
  Iterable<T> get nullableAsIterable {
    final self = this;
    if (self == null) return const [];
    return SingleElementIterable(self);
  }
}

class SingleElementIterable<E> extends Iterable<E> {
  final E _element;

  SingleElementIterable(this._element);

  @override
  Iterator<E> get iterator => _SingleElementIterator(_element);
}

class _SingleElementIterator<E> implements Iterator<E> {
  final E _element;

  _SingleElementIterator(this._element);

  @override
  E get current => _element;

  var _moved = false;

  @override
  bool moveNext() {
    if (_moved) {
      return false;
    } else {
      _moved = true;
      return true;
    }
  }
}

extension MhuIterableNumberExtension on Iterable<num> {
  double? get averageOrNull => isEmpty ? null : average;
}

extension MhuIterableAnyX<T> on T {
  Iterable<T> get toSingleElementIterable => SingleElementIterable(this);
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
