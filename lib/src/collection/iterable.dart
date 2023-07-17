import 'package:collection/collection.dart' as coll;
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

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
