import 'dart:async';

import 'package:logger/logger.dart';

final _logger = Logger();

typedef DisposeAction = FutureOr<void> Function();

abstract interface class Disposable {
  FutureOr<void> dispose();
}

extension DisposableX on Disposable {
  void disposeBy(DspReg? dsp) {
    dsp?.add(dispose);
  }
}

abstract interface class DspReg {
  bool get isDisposed;

  void add(DisposeAction action);

  static const never = _DspRegNever._();

  static Future<T> perform<T>(
    FutureOr<T> Function(DspReg disposers) action,
  ) async {
    final disposers = DspImpl();

    try {
      return await action(disposers);
    } finally {
      await disposers.dispose();
    }
  }
}

class _DspRegNever implements DspReg {
  const _DspRegNever._();

  @override
  void add(FutureOr<void> Function() action) {}

  @override
  bool get isDisposed => false;
}

extension MhuDisposeAnyX<T> on T {
  void disposeWith(
    DspReg? dsp,
    FutureOr<void> Function(T value) action,
  ) {
    dsp?.add(() => action(this));
  }
}

extension MhuDisposerStreamControllerX<T> on StreamController<T> {
  void closeBy(DspReg? dsp) {
    dsp?.add(close);
  }
}

extension MhuDisposerFutureX<T> on Future<T> {
  void awaitBy(DspReg? dsp) => waitBy(dsp);

  void waitBy(DspReg? dsp) {
    dsp?.add(() => this);
  }
}

class DspImpl implements DspReg, Disposable {
  final _disposers = <DisposeAction>[];
  var _isDisposed = false;

  @override
  void add(DisposeAction action) {
    if (isDisposed) {
      _logger.w('DspImpl already disposed!');
      action();
      return;
    }

    _disposers.add(action);
  }

  @override
  bool get isDisposed => _isDisposed;

  @override
  Future<void> dispose() async {
    if (isDisposed) {
      return;
    }
    _isDisposed = true;
    await Future.wait(
      _disposers.map(
        (fn) async => await fn(),
      ),
    );
  }
}

class _RefCountEntry<V> {
  final Future<V> value;
  final DspImpl disposers;
  var count = 0;

  _RefCountEntry(this.value, this.disposers);
}

class RefCountPool<K, V> {
  final Future<V> Function(K key, DspReg disposers) _factory;

  final _entries = <K, _RefCountEntry<V>>{};

  RefCountPool(this._factory);

  Future<V> acquire(K key, DspReg disposers) {
    final entry = _entries.putIfAbsent(key, () {
      final disposers = DspImpl();
      final value = _factory(key, disposers);
      return _RefCountEntry(value, disposers);
    });

    entry.count++;

    disposers.add(() {
      entry.count--;

      if (entry.count == 0) {
        _entries.remove(key);

        return entry.disposers.dispose();
      }
    });

    return entry.value;
  }

  Future<V> call(K key, DspReg disposers) => acquire(key, disposers);

  Future<T> using<T>(
    K key,
    Future<T> Function(V value, DspReg disposer) action,
  ) {
    return DspReg.perform((disposers) async {
      final value = await acquire(key, disposers);
      return await action(value, disposers);
    });
  }
}

extension AcquireX<T> on Future<T> Function(DspReg disposers) {
  Future<V> andPerform<V>(
    Future<V> Function(T value, DspReg disposers) action,
  ) async {
    return DspReg.perform(
      (disposers) async {
        final value = await this(disposers);
        return await action(value, disposers);
      },
    );
  }
}
