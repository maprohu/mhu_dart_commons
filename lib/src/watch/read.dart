part of '../watch.dart';

WatchRead<T> watching<T>(
  Call<T> call, {
  @ext DspReg? disposers,
}) {
  final impl = _WatchReadImpl._(
    _WatchCalc((_) => call()),
  )..disposeBy(disposers);

  return impl.createWatchWrite();
}

WatchRead<V> mapWatchRead<T, V>({
  @ext required WatchRead<T> watchRead,
  required HasReadAttribute<T, V> readAttribute,
}) {
  return watchRead.mapWatchReadFn$(readAttribute.readAttribute);
}

WatchRead<V> mapWatchReadFn<T, V>({
  @ext required WatchRead<T> watchRead,
  required ReadAttribute<T, V> readAttribute,
}) {
  return ComposedWatchRead.readWatchValue(
    readWatchValue: watchRead.mapReadWatchValueFn$(readAttribute),
    distinctValues: () =>
        watchRead.distinctValues().map(readAttribute).distinct(),
    runPaused: watchRead.runPaused,
  );
}
