part of '../functions.dart';

typedef Drain<T> = void Function(T data);

typedef DrainValue<T> = ({
  Drain<T> drain,
  T value,
});

Drain<T> distinctDrain<T>({
  @ext required Drain<T> drain,
  required T initial,
}) {
  var current = initial;

  return (data) {
    if (data != current) {
      current = data;
      drain(data);
    }
  };
}

Drain<H> higherDrain<L, H>({
  @ext required Drain<L> low,
  required Lower<L, H> lower,
}) {
  return (high) {
    low(
      lower(high),
    );
  };
}
