import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'cache.dart';
import 'functions.dart';
import 'dispose.dart';
import 'frp.dart' as frp;

abstract interface class Fr<T> {
  T watch();

  T read();

  Stream<T> changes();
}

abstract interface class Fw<T> extends Fr<T> {
  void set(T value);

  factory Fw.fromFr({
    required Fr<T> fr,
    required void Function(T value) set,
  }) =>
      frw(fr, set);
}

abstract interface class Fu<T> extends Fr<T> {
  void update(void Function(T items) updates);
}

class _FwImpl<T> implements Fw<T>, Disposable {
  final BehaviorSubject<T> _subject;

  static _Calc? _calling;

  _FwImpl._({
    required T value,
  }) : _subject = BehaviorSubject.seeded(value);

  T get value => _subject.value;

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
    if (_subject.value != value) {
      _subject.value = value;
      final downstreamCopy = Set.of(_downstream);
      for (final down in downstreamCopy) {
        down.recalc();
      }
    }
  }

  // ValueStream<T> get stream => _subject;

  @override
  Stream<T> changes() => _subject;

  @override
  Future<void> dispose() async {
    _downstream.clear();
    await _subject.close();
  }
}

class _Calc<T> implements Disposable {
  T Function(DspReg disposers) _calc;

  var _disposers = DspImpl();

  final _upstream = <_FwImpl>{};

  late Frr<T> frr;

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

  void recalc() {
    frr.set(run());
  }

  @override
  Future<void> dispose() async {
    _clearUpstream();
    await _disposers.dispose();
  }
}

class Frr<T> extends _FwImpl<T> {
  final _Calc<T> _calc;

  Frr._(this._calc)
      : super._(
          value: _calc.run(),
        ) {
    _calc.frr = this;
  }

  @override
  Future<void> dispose() async {
    await Future.wait([
      _calc.dispose(),
      super.dispose(),
    ]);
  }
}

// class _FwImpl<T> extends _FrBase<T> implements Fw<T> {
//   _FwImpl._({
//     required T value,
//   }) : super._(value: value);
//
//   set value(T value) {
//     _set(value);
//   }
//
//   void set(T value) {
//     this.value = value;
//   }
//
//   void update(T Function(T v) updates) {
//     value = updates(value);
//   }
// }

Fw<T> fw<T>(
  T value, {
  DspReg? disposers,
}) =>
    _FwImpl._(value: value)..disposeBy(disposers);

Fr<T> fr<T>(
  T Function() calc, {
  DspReg? disposers,
}) =>
    Frr._(
      _Calc((_) => calc()),
    )..disposeBy(disposers);

Fw<T> frw<T>(
  Fr<T> fr,
  void Function(T v) set,
) =>
    _Frw(
      fr: fr,
      set: set,
    );

class _Frw<T> implements Fw<T> {
  final Fr<T> _fr;
  final void Function(T v) _set;

  _Frw({
    required Fr<T> fr,
    required void Function(T v) set,
  })  : _fr = fr,
        _set = set;

  @override
  Stream<T> changes() => _fr.changes();

  @override
  T read() => _fr.read();

  @override
  void set(T value) => _set(value);

  @override
  T watch() => _fr.watch();
}

Fr<T> frDsp<T>(
  T Function(DspReg disposers) calc, {
  DspReg? dsp,
}) =>
    Frr._(
      _Calc(calc),
    )..disposeBy(dsp);

mixin HasFr<T> implements Fr<T> {
  Fr<T> get fv;

  @override
  T watch() => fv.watch();

  @override
  T read() => fv.read();

  @override
  Stream<T> changes() => fv.changes();
}

mixin HasFw<T> implements Fw<T> {
  Fw<T> get fv;

  @override
  T watch() => fv.watch();

  @override
  T read() => fv.read();

  @override
  Stream<T> changes() => fv.changes();

  @override
  void set(T v) => fv.set(v);
}

mixin HasFu<T> implements Fu<T> {
  Fu<T> get fv;

  @override
  T watch() => fv.watch();

  @override
  T read() => fv.read();

  @override
  Stream<T> changes() => fv.changes();

  @override
  void update(void Function(T items) updates) => fv.update(updates);
}

extension FrX<T> on Fr<T> {
  T get value => read();

  T call() => watch();

  void onChange(
    void Function(T value) callback, {
    bool fireImmediately = false,
    DspReg? disposers,
  }) {
    if (fireImmediately) {
      fr(
        () {
          callback(watch());
        },
        disposers: disposers,
      );
    } else {
      onChange(
        callback.skip(1),
        fireImmediately: true,
        disposers: disposers,
      );
    }
  }
}

extension FwX<T> on Fw<T> {
  T get value => read();

  set value(T value) {
    set(value);
  }

  void update(T Function(T v) updates) {
    value = updates(read());
  }
}

class ValConstant<T> implements Fr<T> {
  final T _constant;

  ValConstant(this._constant);

  @override
  T watch() => _constant;

  @override
  T read() => _constant;

  @override
  ValueStream<T> changes() => BehaviorSubject.seeded(_constant);
}

// class ValFunction<T> implements Fr<T> {
//   final T Function() _function;
//
//   ValFunction(this._function);
//
//   @override
//   T watch() => _function();
// }

extension AnyValX<T> on T {
  Fr<T> get vl => ValConstant(this);
}

// extension AnyFnValX<T> on T Function() {
//   Fr<T> get vlfn => ValFunction(this);
// }

// Fr<T> val<T>(T Function() fn) => fn.vlfn;

extension FrpStreamX<T> on Stream<T> {
  Future<Fr<T>> fr(DspReg disposers) async {
    late _FwImpl<T> frw;
    final seeded = Completer<void>();

    late void Function(T value) listener;

    listener = (value) {
      frw = _FwImpl._(
        value: value,
      );
      listener = frw.set;
      seeded.complete(null);
    };

    final listening = listen((v) => listener(v));

    disposers.add(() async {
      await listening.cancel();

      if (!seeded.isCompleted) {
        seeded.completeError('disposed');
      } else {
        await frw.dispose();
      }
    });

    await seeded.future;

    return frw;
  }

  Fr<T> seededVal(T seed, DspReg disposers) {
    final frw = _FwImpl._(value: seed);

    final listening = listen(frw.set);

    disposers.add(() async {
      await listening.cancel();
      await frw.dispose();
    });

    return frw;
  }
}

class CachedFu<T, K, C, F extends Fw<T>> with HasFu<C> {
  @override
  final Fu<C> fv;
  final F Function(K key) _item;

  CachedFu(this.fv, this._item);

  F item(K key) => _item(key);

  static CachedFu<T, int, List<T>, F> list<T, F extends Fw<T>>({
    required Fu<List<T>> fv,
    required F Function(Fw<T> item) wrap,
    T? defaultValue,
  }) {
    final cache = Cache<int, F>((index) {
      final item = fv.itemFwHot(index, defaultValue: defaultValue);
      return wrap(item);
    });
    return CachedFu(fv, cache.get);
  }

  static CachedFu<T, K, Map<K, T>, F> map<T, K, F extends Fw<T>>({
    required Fu<Map<K, T>> fv,
    required F Function(Fw<T> item) wrap,
    T? defaultValue,
  }) {
    final cache = Cache<K, F>((index) {
      final item = fv.itemFwHot(index, defaultValue: defaultValue);
      return wrap(item);
    });
    return CachedFu(fv, cache.get);
  }
}

class CachedFr<T, K, C, F extends Fr<T>> with HasFr<C> {
  @override
  final Fr<C> fv;
  final F Function(K key) _item;

  CachedFr(this.fv, this._item);

  F item(K key) => _item(key);

  static CachedFr<T, int, List<T>, F> list<T, F extends Fr<T>>({
    required Fr<List<T>> fv,
    required F Function(Fr<T> item) wrap,
    T? defaultValue,
  }) {
    final cache = Cache<int, F>((index) {
      final item = fv.itemFrHot(index, defaultValue: defaultValue);
      return wrap(item);
    });
    return CachedFr(fv, cache.get);
  }

  static CachedFr<T, K, Map<K, T>, F> map<T, K, F extends Fr<T>>({
    required Fr<Map<K, T>> fv,
    required F Function(Fr<T> item) wrap,
    T? defaultValue,
  }) {
    final cache = Cache<K, F>((index) {
      final item = fv.itemFrHot(index, defaultValue: defaultValue);
      return wrap(item);
    });
    return CachedFr(fv, cache.get);
  }
}

extension FuCommonMapX<K, V> on Fu<Map<K, V>> {
  Fw<V> itemFw(
    K key, {
    V? defaultValue,
  }) {
    return frw(
      map((t) {
        return t[key] ?? defaultValue!;
      }),
      (value) {
        update((m) {
          m[key] = value;
        });
      },
    );
  }

  Fw<V> itemFwHot(
    K key, {
    V? defaultValue,
    DspReg? disposers,
  }) {
    return frw(
      fr(() {
        return watch()[key] ?? defaultValue!;
      }),
      (value) {
        update((m) {
          m[key] = value;
        });
      },
    );
  }
}

extension FuCommonListX<V> on Fu<List<V>> {
  Fw<V> itemFw(
    int index, {
    V? defaultValue,
  }) {
    return frw(
      map((list) {
        if (index >= list.length) return defaultValue!;
        return list[index];
      }),
      (value) {
        update((list) {
          if (index >= list.length) return;
          list[index] = value;
        });
      },
    );
  }

  Fw<V> itemFwHot(
    int index, {
    V? defaultValue,
  }) {
    return frw(
      fr(() {
        final list = watch();
        if (index >= list.length) return defaultValue!;
        return list[index];
      }),
      (value) {
        update((list) {
          if (index >= list.length) return;
          list[index] = value;
        });
      },
    );
  }
}

class _MappedFr<A, B> implements Fr<B> {
  final Fr<A> _frA;
  final B Function(A a) _mapper;

  _MappedFr(this._frA, this._mapper);

  @override
  Stream<B> changes() => _frA.changes().map(_mapper);

  @override
  B read() => _mapper(_frA.read());

  @override
  B watch() => _mapper(_frA.watch());
}

extension FrCommonX<T> on Fr<T> {
  Fr<V> map<V>(V Function(T t) mapper) => _MappedFr(this, mapper);
}

extension FrCommonListX<V> on Fr<List<V>> {
  Fr<V> itemFrHot(
    int index, {
    V? defaultValue,
    DspReg? disposers,
  }) {
    return fr(() {
      final list = watch();
      if (index >= list.length) return defaultValue!;
      return list[index];
    });
  }
}

extension FrCommonMapX<K, V> on Fr<Map<K, V>> {
  Fr<V> itemFrHot(
    K key, {
    V? defaultValue,
    DspReg? disposers,
  }) {
    return fr(() {
      return watch()[key] ?? defaultValue!;
    });
  }
}

extension FrpDisposersX on DspReg {
  frp.Fw<T> fw<T>(T value) => frp.fw(value, disposers: this);

  frp.Fr<T> fr<T>(T Function() calc) => frp.fr(calc, disposers: this);
}
