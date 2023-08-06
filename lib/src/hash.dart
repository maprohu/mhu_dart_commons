int fastStringHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}
int fastBytesHash(List<int> bytes) {
  var hash = 0xcbf29ce484222325;

  for (final byte in bytes) {
    hash ^= byte;
    hash *= 0x100000001b3;
  }

  return hash;
}