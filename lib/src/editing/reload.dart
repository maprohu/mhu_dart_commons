part of '../editing.dart';

@Has()
sealed class Reloader {}

@Has()
typedef ReloadSync = VoidCall;

@Compose()
abstract class SyncReloader implements Reloader, HasReloadSync, HasWatchDirty {}

@Has()
typedef ReloadAsync = AsyncCall<ReloadSync>;

@Compose()
abstract class AsyncReloader implements Reloader, HasReloadAsync {}

@Has()
typedef WatchDirty = WatchValue<bool>;

typedef CheckDirty<T> = Predicate<T>;

@Has()
typedef CreateDirtyChecker<T> = CheckDirty<T> Function(T value);

@Compose()
abstract class WatchReload<T> implements HasWatchValue<T>, HasReloader {}

@Compose()
abstract class WatchReloadSync<T> implements HasWatchValue<T>, SyncReloader {}

@Compose()
abstract class WatchCheckDirty<T>
    implements HasWatchValue<T>, HasCreateDirtyChecker<T> {}

WatchReloadSync<T> watchReloadSync<T>({
  required ReadWatchValue<T> readWatchValue,
  required CreateDirtyChecker<T> createDirtyChecker,
}) {
  final resultWatch = watchVar(readWatchValue.readValue());

  final checker = watching(
    () => createDirtyChecker(
      resultWatch.watchValue(),
    ),
  );

  return ComposedWatchReloadSync(
    watchValue: resultWatch.watchValue,
    reloadSync: () {
      resultWatch.value = readWatchValue.readValue();
    },
    watchDirty: () {
      return checker.watchValue().call(
            readWatchValue.watchValue(),
          );
    },
  );
}

Future<WatchReload<T>> watchReloadAsync<T>({
  required FutureOr<T> Function() loadValue,
}) async {
  final resultWatch = watchVar(await loadValue());

  return ComposedWatchReload(
    watchValue: resultWatch.watchValue,
    reloader: ComposedAsyncReloader(
      reloadAsync: () async {
        final loaded = await loadValue();

        return () {
          resultWatch.value = loaded;
        };
      },
    ),
  );
}

CheckDirty<T> equalsDirtyChecker<T>(T value) {
  return (element) => value == element;
}
