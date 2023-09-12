part of '../watch.dart';

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
class WatchUpdateGroup {
  static final global = WatchUpdateGroup();

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

extension HasWatchUpdateGroupX on HasWatchUpdateGroup {
  T txn<T>(T Function() action) {
    return watchUpdateGroup.run(action);
  }
}

sealed class _PauseResumeState {
  const _PauseResumeState();

  void pause(_WatchWriteImpl impl);

  void resume(_WatchWriteImpl impl);

  void recalculate(_WatchCalc calc);

  static const _PauseResumeState running = _Running.instance;

  factory _PauseResumeState.paused() = _Paused;
}

class _Paused extends _PauseResumeState {
  _WatchCalc? calc;

  @override
  void pause(_WatchWriteImpl impl) {
    throw impl;
  }

  @override
  void recalculate(_WatchCalc calc) {
    this.calc = calc;
  }

  @override
  void resume(_WatchWriteImpl impl) {
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
  void resume(_WatchWriteImpl impl) {
    throw impl;
  }

  @override
  void pause(_WatchWriteImpl impl) {
    impl._pauseResumeState = _PauseResumeState.paused();
  }

  @override
  void recalculate(_WatchCalc calc) {
    calc._recalcInternal();
  }
}

class _WatchWriteImpl<T> implements Disposable {
  late T _currentValue;
  final _subject = BehaviorSubject<T>();

  _PauseResumeState _pauseResumeState = _PauseResumeState.running;

  late final pauseExecutor = createVoidContextExecutor(
    start: () {
      _pauseResumeState.pause(this);
    },
    end: () {
      _pauseResumeState.resume(this);
    },
  );

  final _updateGroup = WatchUpdateGroup.global;

  static _WatchCalc? _calling;

  _WatchWriteImpl._({
    required T Function(_WatchWriteImpl<T> self) value,
  }) {
    _currentValue = value(this);
    _subject.value = _currentValue;
  }

  T get value => _currentValue;

  T read() => value;

  T watch() {
    final calling = _calling;

    if (calling == null) {
      throw '_WatchWriteImpl.watch() called without a _WatchCalc';
    }

    if (_downstream.add(calling)) {
      calling._upstream.add(this);
    }
    return value;
  }

  final _downstream = <_WatchCalc>{};

  static V _withCaller<V>(_WatchCalc caller, V Function() fn) {
    final saved = _calling;
    _calling = caller;
    try {
      return fn();
    } finally {
      _calling = saved;
    }
  }

  void write(T value) {
    _updateGroup.run(
      () => _writeInternal(value),
    );
  }

  void _updateSubject() {
    if (_subject.value != _currentValue) {
      _subject.value = _currentValue;
    }
  }

  void _writeInternal(T value) {
    if (_currentValue != value) {
      _currentValue = value;
      final downstreamCopy = Set.of(_downstream);
      for (final down in downstreamCopy) {
        down._recalc();
      }
      _updateGroup._runOnSessionEnd(_updateSubject);
    }
  }

  Stream<T> distinctValues() => _subject;

  @override
  Future<void> dispose() async {
    _downstream.clear();
    await _subject.close();
  }

  WatchWrite<T> createWatchWrite() {
    return ComposedWatchWrite(
      readValue: read,
      watchValue: watch,
      distinctValues: distinctValues,
      runPaused: pauseExecutor,
      writeValue: write,
    );
  }
}

class _WatchCalc<T> implements Disposable {
  final T Function(DspReg disposers) _calc;

  var _disposers = DspImpl();

  final _upstream = <_WatchWriteImpl>{};

  late _WatchWriteImpl<T> frr;

  _WatchCalc(this._calc);

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
    return _WatchWriteImpl._withCaller(
      this,
      () => _calc(_disposers),
    );
  }

  void _recalc() {
    frr._pauseResumeState.recalculate(this);
  }

  void _recalcInternal() {
    frr._writeInternal(run());
  }

  @override
  Future<void> dispose() async {
    _clearUpstream();
    await _disposers.dispose();
  }
}

class _WatchReadImpl<T> extends _WatchWriteImpl<T> {
  final _WatchCalc<T> _calc;

  _WatchReadImpl._(this._calc)
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
