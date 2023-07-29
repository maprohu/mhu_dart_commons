int nextPowerOf2(int value) {
  assert(value >= 0);

  value--;
  value |= value >> 1;
  value |= value >> 2;
  value |= value >> 4;
  value |= value >> 8;
  value |= value >> 16;
  value |= value >> 32;
  value++;

  return value;
}

T? constrainOrNull<T extends num>(T input, T min, T max) {
  if (input < min) {
    return min;
  }
  if (input > max) {
    return max;
  }
  return null;
}

extension MathIterableX<T> on Iterable<T> {
  double sumByDouble(double Function(T item) value) {
    var result = 0.0;

    for (final item in this) {
      result += value(item);
    }

    return result;
  }
}
