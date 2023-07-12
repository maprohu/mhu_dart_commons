extension MhuComparatorX<T> on Comparator<T> {
  Comparator<T> get reversed => (a, b) => this(b, a);

  Comparator<T> ascending(bool ascending) {
    if (ascending) {
      return this;
    } else {
      return reversed;
    }
  }
}

extension MhuComparableGetterX<T, V extends Comparable<V>> on V Function(
    T object) {
  Comparator<T> get toComparator => (a, b) => this(a).compareTo(this(b));
}
