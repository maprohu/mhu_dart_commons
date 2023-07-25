import 'compare.dart' as this_lib;

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

extension MhuComparatorNotNullableX<T extends Object> on Comparator<T> {
  Comparator<T?> get nullFirst => this_lib.nullFirst(this);

  Comparator<T?> get nullLast => this_lib.nullLast(this);
}

extension MhuComparableGetterX<T, V extends Comparable<V>> on V Function(
    T object) {
  Comparator<T> get toComparator => (a, b) => this(a).compareTo(this(b));
}

extension MhuComparatorFieldFunctionX<T, F> on F Function(T t) {
  Comparator<T> comparatorField([
    Comparator<F> fieldComparator = compareNaturalOrder,
  ]) =>
      compareByFieldNatural(
        this,
        comparator: fieldComparator,
      );
}

Comparator<T?> nullFirst<T extends Object>(Comparator<T> comparator) {
  return (a, b) {
    return switch ((a, b)) {
      // see: https://github.com/dart-lang/sdk/issues/53033
      // ignore: constant_pattern_never_matches_value_type
      (null, null) => 0,
      // ignore: constant_pattern_never_matches_value_type
      (_, null) => 1,
      // ignore: constant_pattern_never_matches_value_type
      (null, _) => -1,
      _ => comparator(a!, b!),
    };
  };
}

Comparator<T?> nullLast<T extends Object>(Comparator<T> comparator) {
  return (a, b) {
    return switch ((a, b)) {
      // see: https://github.com/dart-lang/sdk/issues/53033
      // ignore: constant_pattern_never_matches_value_type
      (null, null) => 0,
      // ignore: constant_pattern_never_matches_value_type
      (_, null) => -1,
      // ignore: constant_pattern_never_matches_value_type
      (null, _) => 1,
      _ => comparator(a!, b!),
    };
  };
}

int compareNaturalOrder(dynamic a, dynamic b) => (a as Comparable).compareTo(b);

int compareTo<C extends Comparable<C>>(C a, C b) => a.compareTo(b);

int compareToNum(num a, num b) => a.compareTo(b);

Comparator<T> compareByFieldNum<T>(
  num Function(T t) fieldValue,
) =>
    compareByField(
      fieldValue,
    );

Comparator<T> compareByField<T, F extends Comparable<F>>(
  F Function(T t) fieldValue,
) =>
    compareByFieldNatural(
      fieldValue,
      comparator: compareTo<F>,
    );

Comparator<T> compareByFieldNatural<T, F>(
  F Function(T t) fieldValue, {
  Comparator<F> comparator = compareNaturalOrder,
}) {
  return (a, b) {
    return comparator(
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

Comparator<T> compareMany<T>(
  Iterable<Comparator<T>> comparators,
) =>
    comparators.reduce(
      (a, b) => a.thenCompare(b),
    );

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

extension CompareAnyX<T> on T {
  bool equalTo(
    T other, {
    Comparator<T> comparator = compareNaturalOrder,
  }) =>
      comparator(this, other) == 0;

  bool lessThan(
    T other, {
    Comparator<T> comparator = compareNaturalOrder,
  }) =>
      comparator(this, other) < 0;

  bool greaterThan(
    T other, {
    Comparator<T> comparator = compareNaturalOrder,
  }) =>
      comparator(this, other) > 0;
}
