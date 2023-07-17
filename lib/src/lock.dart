import 'dart:async';

import 'package:logger/logger.dart';

import 'dispose.dart';
import 'task_queue.dart';

final _logger = Logger();

class Locker<T> {
  final FutureOr<T> _value;

  Locker(this._value);

  final _queue = TaskQueue(
    disposers: DspImpl(),
  );

  Future<T> acquire(DspReg disposers) {
    final completer = Completer<T>();

    _queue.submit(() async {
      _logger.d('acquire task enter');

      final released = Completer();

      disposers.add(() => released.complete());

      completer.complete(_value);

      await released.future;

      _logger.d('acquire task exit');
    });

    return completer.future;
  }
}
