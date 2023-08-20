part of 'frp.dart';

class _UpdateSession {
  final listeners = <void Function()>[];

  T run<T>(T Function() action) {
    try {
      return action();
    } finally {
      for (final listener in listeners) {
        listener();
      }
    }
  }
}

@Has()
class FwUpdateGroup {
  static final global = FwUpdateGroup();

  _UpdateSession? _current;

  T run<T>(T Function() action) {
    final current = _current;
    if (current != null) {
      return action();
    }
    final session = _UpdateSession();
    _current = session;
    try {
      return session.run(action);
    } finally {
      _current = null;
    }
  }

  void _runOnSessionEnd(void Function() callback) {
    final session = _current;
    if (session == null) {
      callback();
    } else {
      session.listeners.add(callback);
    }
  }
}

extension HasFwUpdateGroupX on HasFwUpdateGroup {
  T txn<T>(T Function() action) {
    return fwUpdateGroup.run(action);
  }
}

sealed class _PauseResumeState {
  const _PauseResumeState();
  void pause(_FwImpl impl);
  void resume(_FwImpl impl);
  void recalc(_Calc calc);

  static const _PauseResumeState running = _Running.instance;

  factory _PauseResumeState.paused() = _Paused;
}
class _Paused extends _PauseResumeState {
  _Calc? calc;
  @override
  void pause(_FwImpl impl) {
    throw impl;
  }
  @override
  void recalc(_Calc calc) {
    this.calc = calc;
  }

  @override
  void resume(_FwImpl impl) {
    final calc = this.calc;
    if (calc != null) {
      calc._recalcInternal();
    }
    impl._pauseResumeState = _PauseResumeState.running;
  }

}
class _Running extends _PauseResumeState {
  const _Running._();
  static const instance = _Running._();

  @override
  void resume(_FwImpl impl) {
    throw impl;
  }

  @override
  void pause(_FwImpl impl) {
    impl._pauseResumeState = _PauseResumeState.paused();
  }

  @override
  void recalc(_Calc calc) {
    calc._recalcInternal();
  }
}

class _FwImpl<T> implements Fw<T>, Disposable {
  late T _currentValue;
  final _subject = BehaviorSubject<T>();

  _PauseResumeState _pauseResumeState = _PauseResumeState.running;

  final _updateGroup = FwUpdateGroup.global;

  static _Calc? _calling;

  _FwImpl._({
    required T Function(_FwImpl<T> self) value,
  }) {
    _currentValue = value(this);
    _subject.value = _currentValue;
  }

  T get value => _currentValue;

  @override
  T read() => value;

  @override
  T watch() {
    final calling = _calling;

    if (calling == null) {
      throw 'Frb.watch() called without a _Calc';
    }

    if (_downstream.add(calling)) {
      calling._upstream.add(this);
    }
    return value;
  }

  final _downstream = <_Calc>{};

  static V _withCaller<V>(_Calc caller, V Function() fn) {
    final saved = _calling;
    _calling = caller;
    try {
      return fn();
    } finally {
      _calling = saved;
    }
  }

  @override
  void set(T value) {
    _updateGroup.run(
      () => _setInternal(value),
    );
  }

  void _updateSubject() {
    if (_subject.value != _currentValue) {
      _subject.value = _currentValue;
    }
  }

  void _setInternal(T value) {
    if (_currentValue != value) {
      _currentValue = value;
      final downstreamCopy = Set.of(_downstream);
      for (final down in downstreamCopy) {
        down._recalc();
      }
      _updateGroup._runOnSessionEnd(_updateSubject);
    }
  }

  @override
  Stream<T> changes() => _subject;

  @override
  Future<void> dispose() async {
    _downstream.clear();
    await _subject.close();
  }

  @override
  void pause() {
    _pauseResumeState.pause(this);
  }

  @override
  void resume() {
    _pauseResumeState.resume(this);
  }
}

class _Calc<T> implements Disposable {
  final T Function(DspReg disposers) _calc;

  var _disposers = DspImpl();

  final _upstream = <_FwImpl>{};

  late _FwImpl<T> frr;

  _Calc(this._calc);

  void _clearUpstream() {
    final upstreamCopy = Set.of(_upstream);
    _upstream.clear();
    for (final up in upstreamCopy) {
      up._downstream.remove(this);
    }
  }

  T run() {
    _clearUpstream();
    _disposers.dispose();
    _disposers = DspImpl();
    return _FwImpl._withCaller(
      this,
      () => _calc(_disposers),
    );
  }

  void _recalc() {
    frr._pauseResumeState.recalc(this);
  }

  void _recalcInternal() {
    frr._setInternal(run());
  }

  @override
  Future<void> dispose() async {
    _clearUpstream();
    await _disposers.dispose();
  }
}

class _Frr<T> extends _FwImpl<T> {
  final _Calc<T> _calc;

  _Frr._(this._calc)
      : super._(
          value: (self) {
            _calc.frr = self;
            return _calc.run();
          },
        );

  @override
  Future<void> dispose() async {
    await Future.wait([
      _calc.dispose(),
      super.dispose(),
    ]);
  }
}
