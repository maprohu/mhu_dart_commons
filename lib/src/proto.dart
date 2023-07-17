import 'package:protobuf/protobuf.dart';

import 'kt.dart';

extension MhuBaseGeneratedMessageX<M extends GeneratedMessage> on M {
  M deepRebuild(void Function(M message) updates) {
    return deepCopy().also(updates)..freeze();
  }

  M selectRebuild<S>({
    required S Function(M message) select,
    required void Function(S selected) updates,
  }) {
    return deepRebuild(
      (message) => updates(
        select(message),
      ),
    );
  }
}
