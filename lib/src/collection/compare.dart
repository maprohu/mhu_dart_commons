extension MhuComparatorX<T> on Comparator<T> {
  Comparator<T> get reversed => (a, b) => this(b, a);

  Comparator<T> ascending(bool ascending) {
    if (ascending) {
      return this;
    } else {
      return reversed;
    }
  }

  Comparator<T> thenCompare(Comparator<T> comparator) => (a, b) {
        final firstResult = this.call(a, b);
        if (firstResult != 0) {
          return firstResult;
        } else {
          return comparator(a, b);
        }
      };
}

extension MhuComparableGetterX<T, V extends Comparable<V>> on V Function(
    T object) {
  Comparator<T> get toComparator => (a, b) => this(a).compareTo(this(b));
}

extension MhuComparatorFieldFunctionX<T, F> on F Function(T t) {
  Comparator<T> comparatorField([
    Comparator<F> fieldComparator = compareNaturalOrder,
  ]) =>
      compareByField(
        this,
        fieldComparator,
      );
}

int compareNaturalOrder(dynamic a, dynamic b) => (a as Comparable).compareTo(b);

Comparator<T> compareByField<T, F>(
  F Function(T t) fieldValue, [
  Comparator<F> fieldComparator = compareNaturalOrder,
]) {
  return (a, b) {
    return fieldComparator(
      fieldValue(a),
      fieldValue(b),
    );
  };
}

Comparator<T> compare2<T>(
  Comparator<T> c1,
  Comparator<T> c2,
) =>
    c1.thenCompare(c2);

Comparator<T> compare3<T>(
  Comparator<T> c1,
  Comparator<T> c2,
  Comparator<T> c3,
) =>
    c1.thenCompare(c2).thenCompare(c3);

T max2<T>(
  T a,
  T b, [
  Comparator<T> comparator = compareNaturalOrder,
]) =>
    comparator(a, b) > 0 ? a : b;

T min2<T>(
  T a,
  T b, [
  Comparator<T> comparator = compareNaturalOrder,
]) =>
    comparator(a, b) < 0 ? a : b;
