part of 'frp.dart';

extension FwOfInt64X on Fw<Int64> {
  Int64 incrementAndRead() {
    final incrementedValue = read() + 1;
    value = incrementedValue;
    return incrementedValue;
  }
}
