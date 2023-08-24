import 'holder.dart';

typedef VoidContextExecutor = R Function<R>(R Function() action);
typedef ContextExecutor<C> = R Function<R>(R Function(C context) action);

ContextExecutor<C> createContextExecutor<C>({
  required C Function() create,
  required void Function(C context) destroy,
}) {
  Holder<C>? contextHolder;

  return <R>(action) {
    final currentContextHolder = contextHolder;
    if (currentContextHolder != null) {
      return action(currentContextHolder.value);
    } else {
      final context = create();
      contextHolder = Holder(context);
      try {
        return action(context);
      } finally {
        contextHolder = null;
        destroy(context);
      }
    }
  };
}

VoidContextExecutor createVoidContextExecutor({
  required void Function() start,
  required void Function() end,
}) {
  final executor = createContextExecutor<void>(
    create: start,
    destroy: (_) => end(),
  );

  return <R>(action) {
    return executor(
      (_) => action(),
    );
  };
}
