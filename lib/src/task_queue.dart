import 'dart:async';

import 'async.dart';

import 'dispose.dart';

class TaskQueue {
  final DspReg _disposers;

  final _queue = StreamController<Future<void> Function()>();


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

    _queue.add(
      () => completer.completeWith(task),
    );

    return await completer.future;
  }

  Future<T> submitOrRun<T>(Future<T> Function() task) async {
    if (_disposers.isDisposed) {
      return await task();
    } else {
      return await submit(task);
    }
  }
}
