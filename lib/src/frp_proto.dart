import 'package:protobuf/protobuf.dart';

import 'dispose.dart';
import 'frp.dart';
import 'proto.dart';

Fu<F> fuHot<M extends GeneratedMessage, F>(
  Fw<M> fw,
  F Function(M m) get, {
  DspReg? disposers,
}) {
  return Fu.fromFr(
    fr: fr(
      () => get(fw.watch()),
      disposers: disposers,
    ),
    update: (updates) => fw.rebuild((message) {
      updates(get(message));
    }),
  );
}

Fu<F> fuCold<M extends GeneratedMessage, F>(
  Fw<M> fw,
  F Function(M m) get,
) {
  return Fu.fromFr(
    fr: fw.map(get),
    update: (updates) => fw.rebuild((message) {
      updates(get(message));
    }),
  );
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

  Fw<F> protoField<F>({
    required F Function(M message) get,
    required void Function(M message, F value) set,
  }) {
    return field(
      get: get,
      set: (message, value) => message.rebuild(
        (b) {
          set(b, value);
        },
      ),
    );
  }
}
