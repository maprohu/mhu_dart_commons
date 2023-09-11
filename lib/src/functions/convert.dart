part of '../functions.dart';

typedef Convert<A, B> = B Function(A value);

Convert<A?, B?> convertNullable<A extends Object, B extends Object>({
  @ext required Convert<A, B> convert,
}) {
  return (value) {
    if (value == null) {
      return null;
    } else {
      return convert(value);
    }
  };
}
