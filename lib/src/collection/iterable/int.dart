part of '../iterable.dart';

typedef SomeIntsPair = (SomeInts, SomeInts);

sealed class Ints {
  const Ints._();

  factory Ints.inclusive({
    required int from,
    required int to,
  }) {
    return Ints(
      from: from,
      until: to + 1,
    );
  }

  factory Ints({
    required int from,
    required int until,
  }) {
    if (from < until) {
      return SomeInts(from: from, until: until);
    } else {
      return EmptyInts();
    }
  }
}

class EmptyInts extends Ints {
  const EmptyInts() : super._();
}

class SomeInts extends Ints {
  final int from;
  final int until;

  const SomeInts({
    required this.from,
    required this.until,
  })  : assert(from < until),
        super._();

  int get first => from;

  int get last => until - 1;

  const SomeInts.single(int number)
      : from = number,
        until = number + 1,
        super._();
}

SomeIntsPair someIntsOrdered(
  SomeInts a,
  SomeInts b,
) {
  if (a.from > b.from) {
    return (b, a);
  } else {
    return (a, b);
  }
}

Ints intsIntersect({
  @ext required Ints a,
  required Ints b,
}) {
  Ints some(SomeInts a, SomeInts b) {
    final from = max(a.from, b.from);
    final until = min(a.until, b.until);

    return Ints(
      from: from,
      until: until,
    );
  }

  return switch (a) {
    EmptyInts() => const EmptyInts(),
    SomeInts() => switch (b) {
        EmptyInts() => const EmptyInts(),
        SomeInts() => some(a, b),
      }
  };
}

Iterable<int> intsIterable({
  @ext required Ints ints,
}) {
  return switch (ints) {
    EmptyInts() => const Iterable.empty(),
    SomeInts() => integers(
        from: ints.from,
      ).take(
        ints.intsCount(),
      ),
  };
}

Ints intsMapSome({
  @ext required Ints ints,
  required Ints Function(SomeInts someInts) mapper,
}) {
  return switch (ints) {
    EmptyInts() => const EmptyInts(),
    SomeInts() => mapper(ints),
  };
}

Ints intsShrinkSymmetric({
  @ext required Ints ints,
  required int count,
}) {
  assert(count >= 0);

  return ints.intsMapSome$(
    (someInts) => Ints(
      from: someInts.from + count,
      until: someInts.until - count,
    ),
  );
}

SomeInts intsGrowSymmetric({
  @ext required SomeInts someInts,
  required int count,
}) {
  assert(count >= 0);

  return SomeInts(
    from: someInts.from - count,
    until: someInts.until + count,
  );
}

int intsCount({
  @ext required Ints ints,
}) {
  return switch (ints) {
    EmptyInts() => 0,
    SomeInts() => ints.until - ints.from,
  };
}
