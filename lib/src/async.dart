import 'dart:async';


import 'package:logger/logger.dart';
import 'package:mhu_dart_commons/commons.dart';

final _logger = Logger();

typedef AsyncVoidFunction = AsyncFunction<void>;
typedef AsyncFunction<T> = Future<T> Function();

extension CompleterX<T> on Completer<T> {
  Future<void> completeWith(FutureOr<T> Function() fn) async {
    try {
      complete(await fn());
    } catch (e) {
      completeError(e);
    }
  }

  Future<void> completeWithSync(T Function() fn) async {
    try {
      complete(fn());
    } catch (e) {
      completeError(e);
    }
  }

  bool completeOnce([FutureOr<T>? value]) {
    if (!isCompleted) {
      complete(value);
      return true;
    } else {
      return false;
    }
  }

  bool completeOnceError(
    Object error, [
    StackTrace? stackTrace,
  ]) {
    if (!isCompleted) {
      completeError(error, stackTrace);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> completeOnceWith(FutureOr<T> Function() fn) async {
    if (!isCompleted) {
      try {
        return completeOnce(await fn());
      } catch (e) {
        return completeOnceError(e);
      }
    } else {
      return false;
    }
  }
}

class Futures {
  static final Future<void> voidValue = Future.value();

  static Future<void> voidFn() => voidValue;
}

extension IterableFuturesX<T> on Iterable<Future<T>> {
  Future<List<T>> futureWait() => Future.wait(this);
}

class LatestExecutor<T extends Object> {
  final DspReg _disposers;
  final Future<void> Function(T value) process;
  Completer? _working;
  T? _next;

  void _process() async {
    final working = Completer();
    _working = working;
    while (true) {
      final current = _next;
      _next = null;

      if (current == null) {
        working.complete();
        _working = null;
        return;
      }

      await process(current);
    }
  }

  void submit(T value) {
    if (_disposers.isDisposed) {
      _logger.w('LatestExecutor already disposed!');
      return;
    }

    if (_working == null) {
      _working = Completer();
      _next = value;
      _process();
    } else {
      _next = value;
    }
  }

  LatestExecutor({
    required this.process,
    required DspReg disposers,
  }) : _disposers = disposers {
    disposers.add(() async {
      await _working?.future;
    });
  }
}
