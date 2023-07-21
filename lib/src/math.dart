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
