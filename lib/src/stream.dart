import 'dart:async';

import 'package:mhu_dart_commons/commons.dart';

import 'functions.dart';

extension MhuStreamX<T> on Stream<T> {
  Future<void> asyncForEach(FutureOr<void> Function(T value) action) async {
    await for (final value in this) {
      await action(value);
    }
  }

  StreamSubscription<T> asyncListen(
    Future<void> Function(T event) onData,
  ) {
    return asyncMap(
      (value) async {
        await onData(value);
        return value;
      },
    ).listen(ignore1);
  }
}

extension MhuStreamOfIterablesX<T> on Stream<Iterable<T>> {
  Stream<T> get flatten => expand(identity);
}

extension StreamSubscriptionX<T> on StreamSubscription<T> {
  void cancelBy(DspReg? disposers) {
    disposers?.add(cancel);
  }
}
