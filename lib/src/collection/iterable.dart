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
}

extension NullabeIterableX<T> on T? {
  Iterable<T> get nullableAsIterable {
    final self = this;
    if (self == null) return const [];
    return _SingleElementIterable(self);
  }
}

class _SingleElementIterable<E> extends Iterable<E> {
  final E _element;

  _SingleElementIterable(this._element);

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
