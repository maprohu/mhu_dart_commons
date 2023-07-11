import 'dart:async';

typedef DisposeAction = FutureOr<void> Function();

abstract interface class DspReg {
  bool get isDisposed;

  void add(DisposeAction action);

  static const never = _DspRegNever._();
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
  void waitBy(DspReg? dsp) {
    dsp?.add(() => this);
  }
}
