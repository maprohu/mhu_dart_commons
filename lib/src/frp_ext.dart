part of 'frp.dart';

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

  Fr<V> map<V>(V Function(T t) mapper) => _MappedFr(this, mapper);
}

extension FwX<T> on Fw<T> {
  T get value => read();

  set value(T value) {
    set(value);
  }

  void update(T Function(T v) updates) {
    value = updates(read());
  }

  Fw<V> castFw<V>() => bidiMap(
        BiDi.bidiCast<T, V>(),
      );

  Fw<V> bidiMap<V>(
    BiDi<T, V> bidi,
  ) {
    return Fw.fromFr(
      fr: map(bidi.forward),
      set: (value) => set(
        bidi.backward(value),
      ),
    );
  }

  Fw<F> field<F>({
    required F Function(T message) get,
    required T Function(T message, F value) set,
  }) {
    return Fw.fromFr(
      fr: map(get),
      set: (value) => update(
        (message) => set(message, value),
      ),
    );
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
        if (index >= list.length) {
          return defaultValue ?? (throw 'itemFw defaultValue is null');
        }
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
    DspReg? disposers,
  }) {
    return frw(
      fr(
        () {
          final list = watch();
          if (index >= list.length) {
            return defaultValue ?? (throw 'itemFwHot defaultValue is null');
          }
          return list[index];
        },
        disposers: disposers,
      ),
      (value) {
        update((list) {
          if (index >= list.length) return;
          list[index] = value;
        });
      },
    );
  }
}

extension FrCommonListX<V> on Fr<List<V>> {
  Fr<V> itemFrHot(
    int index, {
    V? defaultValue,
    DspReg? disposers,
  }) {
    return fr(
      () {
        final list = watch();
        if (index >= list.length) {
          return defaultValue ?? (throw 'defaultValue is null');
        }
        return list[index];
      },
      disposers: disposers,
    );
  }
}

extension FrCommonMapX<K, V> on Fr<Map<K, V>> {
  Fr<V> itemFr(
    K key, {
    V? defaultValue,
  }) {
    return map((t) {
      return t[key] ?? defaultValue!;
    });
  }

  Fr<V> itemFrHot(
    K key, {
    V? defaultValue,
    DspReg? disposers,
  }) {
    return fr(
      () {
        return watch()[key] ?? defaultValue!;
      },
      disposers: disposers,
    );
  }
}

extension FrpDisposersX on DspReg {
  frp.Fw<T> fw<T>(T value) => frp.fw(value, disposers: this);

  frp.Fr<T> fr<T>(T Function() calc) => frp.fr(calc, disposers: this);
}

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
