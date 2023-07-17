import 'package:protobuf/protobuf.dart';

import 'dispose.dart';
import 'frp.dart';
import 'proto.dart';

Fu<F> fru<M extends GeneratedMessage, F>(
    Fw<M> fw,
    F Function(M m) get, {
      DspReg? disposers,
    }) =>
    _Fu(
      fr: fr(
            () => get(fw.watch()),
        disposers: disposers,
      ),
      update: (updates) => fw.rebuild((message) {
        updates(get(message));
      }),
    );

class _Fu<T> implements Fu<T> {
  final Fr<T> _fr;
  final void Function(void Function(T value) updates) _update;

  _Fu({
    required Fr<T> fr,
    required void Function(void Function(T value) updates) update,
  })  : _fr = fr,
        _update = update;

  @override
  Stream<T> changes() => _fr.changes();

  @override
  T read() => _fr.read();

  @override
  T watch() => _fr.watch();

  @override
  void update(void Function(T value) updates) => _update(updates);
}

extension FwProtoX<M extends GeneratedMessage> on Fw<M> {
  void rebuild(void Function(M message) updates) {
    update(
          (v) => v.rebuild(updates),
    );
  }

  void deepRebuild(void Function(M message) updates) {
    update(
          (v) => v.deepRebuild(updates),
    );
  }

  void selectRebuild<S>({
    required S Function(M message) select,
    required void Function(S selected) updates,
  }) {
    update(
          (v) => v.selectRebuild(
        select: select,
        updates: updates,
      ),
    );
  }
}
