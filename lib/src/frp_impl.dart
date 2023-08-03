part of 'frp.dart';

class _UpdateSession {
  final _FwImpl updating;
  final listeners = <void Function()>[];

  _UpdateSession(this.updating);

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
class _UpdateGroup {
  static final global = _UpdateGroup();

  _UpdateSession? current;

  T run<T>(_FwImpl updating, T Function() action) {
    if (current != null) {
      throw 'update already running';
    }
    final session = _UpdateSession(updating);
    current = session;
    try {
      return session.run(action);
    } finally {
      current = null;
    }
  }

  void runOnSessionEnd(void Function() callback) {
    final session = current;
    if (session == null) {
      callback();
    } else {
      session.listeners.add(callback);
    }
  }
}
class _FwImpl<T> implements Fw<T>, Disposable {
  late T _currentValue;
  final _subject = BehaviorSubject<T>();

  final _updateGroup = _UpdateGroup.global;

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
      this,
          () => _setInternal(value),
    );
  }

  void _updateSubject() {
    if (_currentValue != _subject.value) {
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
      _updateGroup.runOnSessionEnd(_updateSubject);
    }
  }

  @override
  Stream<T> changes() => _subject;

  @override
  Future<void> dispose() async {
    _downstream.clear();
    await _subject.close();
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
    final result = _FwImpl._withCaller(
      this,
          () => _calc(_disposers),
    );
    return result;
  }

  void _recalc() {
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
