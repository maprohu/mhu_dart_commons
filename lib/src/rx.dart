import 'package:mhu_dart_commons/src/dispose.dart';
import 'package:rxdart/rxdart.dart';

abstract interface class RxVal<T> {
  T get value;

  Stream<T> get stream;
}

abstract interface class RxVar<T> extends RxVal<T> {
  set value(T value);
}

extension MhuRxValX<T> on RxVal<T> {
  RxVal<V> map<V>(V Function(T value) mapper) => _MappedRxVal(
        rxVal: this,
        mapper: mapper,
      );
}

extension MhuRxVarX<T> on RxVar<T> {
  T update(T Function(T value) update) {
    final newValue = update(value);
    value = newValue;
    return newValue;
  }

  RxVar<V> mapVar<V>({
    required V Function(T value) mapper,
    required T Function(T t, V v) setter,
  }) =>
      _MappedRxVar(
        rxVar: this,
        mapper: mapper,
        setter: setter,
      );
}

class BehaviorSubjectRxVar<T> implements RxVar<T> {
  final BehaviorSubject<T> _subject;

  BehaviorSubjectRxVar._(this._subject);

  BehaviorSubjectRxVar(
    T value, {
    DspReg? dsp,
  }) : this._(
          BehaviorSubject.seeded(value)..closeBy(dsp),
        );

  @override
  T get value => _subject.value;

  @override
  set value(T value) {
    if (_subject.value != value) {
      _subject.value = value;
    }
  }

  @override
  Stream<T> get stream => _subject;
}

RxVar<T> rxw<T>(
  T initial, {
  DspReg? dsp,
}) =>
    BehaviorSubjectRxVar(
      initial,
      dsp: dsp,
    );

class _MappedRxVal<A, B> implements RxVal<B> {
  final RxVal<A> rxVal;
  final B Function(A value) mapper;

  const _MappedRxVal({
    required this.rxVal,
    required this.mapper,
  });

  @override
  Stream<B> get stream => rxVal.stream.map(mapper).distinct();

  @override
  B get value => mapper(rxVal.value);
}

class _MappedRxVar<A, B> extends _MappedRxVal<A, B> implements RxVar<B> {
  void Function(B value) setter;

  static void Function(B value) _setter<A, B>({
    required RxVar<A> rxVar,
    required A Function(A a, B b) setter,
  }) {
    return (b) {
      rxVar.update((a) => setter(a, b));
    };
  }

  _MappedRxVar({
    required RxVar<A> rxVar,
    required super.mapper,
    required A Function(A a, B b) setter,
  })  : setter = _setter(rxVar: rxVar, setter: setter),
        super(
          rxVal: rxVar,
        );

  @override
  set value(B value) {
    setter(value);
  }
}
