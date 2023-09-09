import 'dart:async';

import 'package:async/async.dart';
import 'package:logger/logger.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';

import 'async.dart' as $lib;

part 'async.g.dart';

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

class LatestExecutor<T> {
  final DspReg _disposers;
  final Future<void> Function(T value) process;
  Completer? _working;
  late T _next;
  bool _hasNext = false;

  void _process() async {
    final working = Completer();
    _working = working;
    while (true) {
      if (!_hasNext) {
        _working = null;
        working.complete();
        return;
      }

      _hasNext = false;
      final current = _next;

      await process(current);
    }
  }

  void submit(T value) {
    if (_disposers.isDisposed) {
      _logger.w('LatestExecutor already disposed!');
      return;
    }

    _next = value;
    _hasNext = true;

    if (_working == null) {
      _process();
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

CancelableOperation<T> constantCancelableOperation<T>({
  @ext required T value,
}) {
  return CancelableOperation.fromValue(value);
}

CancelableOperation<B> thenCancelable<A, B>({
  @ext required CancelableOperation<A> cancelableOperation,
  required CancelableOperation<B> Function(A result) then,
}) {
  return cancelableOperation.thenOperation(
    (result, completer) {
      completer.completeOperation(
        then(result),
      );
    },
  );
}
