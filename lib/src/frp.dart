import 'dart:async';

import 'package:collection/collection.dart';
import 'package:mhu_dart_commons/src/collection/compare.dart';
import 'package:rxdart/rxdart.dart';

import 'bidi.dart';
import 'cache.dart';
import 'functions.dart';
import 'dispose.dart';
import 'frp.dart' as frp;

part 'frp_ext.dart';

typedef Watch<T> = T Function();
typedef Watch1<T, P1> = T Function(P1 p1);

abstract interface class Fr<T> {
  T watch();

  T read();

  /// "changes" is not a great name since, by contract, the stream
  /// includes the initial, not yet changed value.
  /// maybe rename it to "distinctValues()" ?
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
        down._recalc();
      }
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

  void _recalc() {
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
  Fr<T> get fv$;

  @override
  T watch() => fv$.watch();

  @override
  T read() => fv$.read();

  @override
  Stream<T> changes() => fv$.changes();
}

mixin HasFw<T> implements Fw<T> {
  Fw<T> get fv$;

  @override
  T watch() => fv$.watch();

  @override
  T read() => fv$.read();

  @override
  Stream<T> changes() => fv$.changes();

  @override
  void set(T v) => fv$.set(v);
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

// class ValConstant<T> implements Fr<T> {
//   final T _constant;
//
//   ValConstant(this._constant);
//
//   @override
//   T watch() => _constant;
//
//   @override
//   T read() => _constant;
//
//   @override
//   ValueStream<T> changes() => BehaviorSubject.seeded(_constant);
// }

// class ValFunction<T> implements Fr<T> {
//   final T Function() _function;
//
//   ValFunction(this._function);
//
//   @override
//   T watch() => _function();
// }

// extension AnyValX<T> on T {
//   Fr<T> get vl => ValConstant(this);
// }

// extension AnyFnValX<T> on T Function() {
//   Fr<T> get vlfn => ValFunction(this);
// }

// Fr<T> val<T>(T Function() fn) => fn.vlfn;

typedef MapFu<K, V> = CachedFu<V, K, Map<K, V>, Fw<V>>;
typedef ListFu<V> = CachedFu<V, int, List<V>, Fw<V>>;

class CachedFu<T, K, C, F extends Fw<T>> with HasFu<C> {
  @override
  final Fu<C> fv;
  final F Function(K key) _item;
  final T? Function(C collection, K key) _get;
  final Iterable<K> Function(C collecion) _keys;
  final Iterable<K> Function(C collecion) _sortedKeys;
  final DspReg? _disposers;

  F item(K key) => _item(key);

  late final _getCache = Cache<K, Fr<T?>>((key) {
    return fr(
      () => _get(fv(), key),
      disposers: _disposers,
    );
  });

  Fr<T?> get(K key) => _getCache.get(key);

  late final _existsCache = Cache<K, Fr<bool>>((key) {
    final getFr = get(key);
    return fr(
      () => getFr() != null,
      disposers: _disposers,
    );
  });

  Fr<bool> exists(K key) => _existsCache.get(key);

  late final keys = fr(
    () => _keys(fv()),
    disposers: _disposers,
  );

  late final sortedKeys = fr(
    () => _sortedKeys(fv()),
    disposers: _disposers,
  );

  static CachedFu<T, int, List<T>, F> list<T, F extends Fw<T>>({
    required Fu<List<T>> fv,
    required F Function(Fw<T> item) wrap,
    T? defaultValue,
    DspReg? disposers,
  }) {
    final cache = Cache<int, F>((index) {
      final item = fv.itemFwHot(
        index,
        defaultValue: defaultValue,
        disposers: disposers,
      );
      return wrap(item);
    });
    return CachedFu(
      fv: fv,
      item: cache.get,
      get: (collection, key) =>
          key < collection.length ? collection[key] : null,
      keys: (collecion) => collecion.mapIndexed((index, element) => index),
      sortedKeys: (collecion) =>
          collecion.mapIndexed((index, element) => index),
      disposers: disposers,
    );
  }

  static CachedFu<T, K, Map<K, T>, F> map<T, K, F extends Fw<T>>({
    required Fu<Map<K, T>> fv,
    required F Function(Fw<T> item) wrap,
    T? defaultValue,
    DspReg? disposers,
  }) {
    final cache = Cache<K, F>((index) {
      final item = fv.itemFwHot(
        index,
        defaultValue: defaultValue,
        disposers: disposers,
      );
      return wrap(item);
    });
    return CachedFu(
      fv: fv,
      item: cache.get,
      get: (collection, key) => collection[key],
      keys: (collecion) => collecion.keys,
      sortedKeys: (collecion) => collecion.keys.sorted(compareNaturalOrder),
      disposers: disposers,
    );
  }

  CachedFu({
    required this.fv,
    required F Function(K key) item,
    required T? Function(C collection, K key) get,
    required Iterable<K> Function(C collecion) keys,
    required Iterable<K> Function(C collecion) sortedKeys,
    required DspReg? disposers,
  })  : _item = item,
        _get = get,
        _keys = keys,
        _sortedKeys = sortedKeys,
        _disposers = disposers;
}

class CachedFr<T, K, C, F extends Fr<T>> with HasFr<C> {
  @override
  final Fr<C> fv$;
  final F Function(K key) _item;

  CachedFr(this.fv$, this._item);

  F item(K key) => _item(key);

  static CachedFr<T, int, List<T>, F> list<T, F extends Fr<T>>({
    required Fr<List<T>> fv,
    required F Function(Fr<T> item) wrap,
    T? defaultValue,
    DspReg? disposers,
  }) {
    final cache = Cache<int, F>((index) {
      final item = fv.itemFrHot(
        index,
        defaultValue: defaultValue,
        disposers: disposers,
      );
      return wrap(item);
    });
    return CachedFr(fv, cache.get);
  }

  static CachedFr<T, K, Map<K, T>, F> map<T, K, F extends Fr<T>>({
    required Fr<Map<K, T>> fv,
    required F Function(Fr<T> item) wrap,
    T? defaultValue,
    DspReg? disposers,
  }) {
    final cache = Cache<K, F>((index) {
      final item = fv.itemFrHot(
        index,
        defaultValue: defaultValue,
        disposers: disposers,
      );
      return wrap(item);
    });
    return CachedFr(fv, cache.get);
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
