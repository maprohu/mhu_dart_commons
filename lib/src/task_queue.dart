import 'dart:async';

import 'frp.dart';

import 'async.dart';

import 'dispose.dart';

class TaskQueue {
  final DspReg _disposers;

  final _queue = StreamController<Future<void> Function()>();

  late final _count = _disposers.fw(0);

  Fr<int> get count => _count;

  late final busy = _disposers.fr(() => count() > 0);

  TaskQueue({
    required DspReg disposers,
  }) : _disposers = disposers {
    () async {
      await for (final task in _queue.stream) {
        await task();
      }
    }();
    _disposers.add(() async {
      await _queue.close();
    });
  }

  Future<T> submit<T>(Future<T> Function() task) async {
    final completer = Completer<T>();

    _count.update((v) => v + 1);

    _queue.add(
      () => completer.completeWith(task),
    );

    try {
      return await completer.future;
    } finally {
      _count.update((v) => v - 1);
    }
  }

  Future<T> submitOrRun<T>(Future<T> Function() task) async {
    if (_disposers.isDisposed) {
      return await task();
    } else {
      return await submit(task);
    }
  }
}
