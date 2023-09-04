part of '../watch.dart';

WatchWrite<T> watchVar<T>(
  T value, {
  @ext DspReg? disposers,
}) {
  final impl = _WatchWriteImpl._(
    value: (_) => value,
  )..disposeBy(disposers);

  return impl.createWatchWrite();
}

WatchWrite<T> watchReadWrite<T>({
  @ext required WatchRead<T> read,
  required WriteValue write,
}) {
  return ComposedWatchWrite.watchRead(
    watchRead: read,
    writeValue: write,
  );
}

WatchWrite<F> mapWatchWrite<M, F>({
  @ext required WatchWrite<M> watchWrite,
  required ReadWriteAttribute<M, F> readWriteAttribute,
  required RebuildMessage<M> rebuildMessage,
}) {
  return ComposedWatchWrite.watchRead(
    watchRead: watchWrite.mapWatchRead(
      readAttribute: readWriteAttribute,
    ),
    writeValue: watchWrite
        .readWriteValueRebuild(
          writeAttribute: readWriteAttribute,
          rebuildMessage: rebuildMessage,
        )
        .writeValue,
  );
}

// WatchWrite<F> mapWatchWriteOpt<M extends Object, F>({
//   @ext required WatchWriteOpt<M> watchWrite,
//   required ReadWriteAttribute<M, F> readWriteAttribute,
//   required RebuildMessage<M> rebuildMessage,
//   required M Function(F value) missingMessage,
// }) {
//   return ComposedWatchWrite.watchRead(
//     watchRead: watchWrite.mapWatchRead(
//       readAttribute: readWriteAttribute,
//     ),
//     writeValue: (value) {
//       final msg = watchWrite.readValue() ?? missingMessage(value);
//       watchWrite.writeValue(
//         rebuildMessage(
//           msg,
//           (msg) {
//             readWriteAttribute.writeAttribute(
//               msg,
//               value,
//             );
//           },
//         ),
//       );
//     },
//   );
// }

// WatchWrite<F> mapWatchWriteOptEnsure<M extends Object, F>({
//   @ext required WatchWriteOpt<M> watchWrite,
//   required ReadWriteAttribute<M, F> readWriteAttribute,
//   required RebuildMessage<M> rebuildMessage,
//   required M defaultMessage,
// }) {
//   return mapWatchWriteOpt(
//     watchWrite: watchWrite,
//     readWriteAttribute: readWriteAttribute,
//     rebuildMessage: rebuildMessage,
//     missingMessage: (_) => defaultMessage,
//   );
// }

// WatchWrite<F> mapWatchWriteOptRequire<M extends Object, F>({
//   @ext required WatchWriteOpt<M> watchWrite,
//   required ReadWriteAttribute<M, F> readWriteAttribute,
//   required RebuildMessage<M> rebuildMessage,
// }) {
//   return mapWatchWriteOpt(
//     watchWrite: watchWrite,
//     readWriteAttribute: readWriteAttribute,
//     rebuildMessage: rebuildMessage,
//     missingMessage: (value) {
//       throw ['attempt to update null msg', M, F, value];
//     },
//   );
// }
