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
}
