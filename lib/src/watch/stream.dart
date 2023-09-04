part of '../watch.dart';

Future<WatchRead<T>> streamWatchRead<T>(
  DspReg disposers, {
  @ext required Stream<T> stream,
}) async {
  late _WatchWriteImpl<T> watchWriteImpl;
  final seeded = Completer<void>();

  late void Function(T value) listener;

  listener = (value) {
    watchWriteImpl = _WatchWriteImpl._(
      value: (_) => value,
    );
    listener = watchWriteImpl.write;
    seeded.complete(null);
  };

  final listening = stream.listen((v) => listener(v));

  disposers.add(() async {
    await listening.cancel();

    if (!seeded.isCompleted) {
      seeded.completeError('disposed');
    } else {
      await watchWriteImpl.dispose();
    }
  });

  await seeded.future;

  return watchWriteImpl.createWatchWrite();
}
