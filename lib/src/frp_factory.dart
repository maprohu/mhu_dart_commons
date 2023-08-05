part of 'frp.dart';

Fw<T> fw<T>(
  T value, {
  DspReg? disposers,
}) =>
    _FwImpl._(
      value: (_) => value,
    )..disposeBy(disposers);

Fr<T> fr<T>(
  T Function() calc, {
  DspReg? disposers,
}) =>
    _Frr._(
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
    _Frr._(
      _Calc(calc),
    )..disposeBy(dsp);

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
