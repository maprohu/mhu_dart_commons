part of '../editing.dart';

extension ReadWriteValueX<T> on HasWriteValue<T> {
  set value(T value) {
    writeValue(value);
  }

  // T get value => readValue();
}

void updateReadWriteValue<T>(
  @ext ReadWriteValue<T> readWriteValue,
  T Function(T value) update,
) {
  readWriteValue.writeValue(
    update(
      readWriteValue.readValue(),
    ),
  );
}

// extension ReadWriteValueX<T> on ReadWriteValue<T?> {
//   UpdateValue<T> updateMessage(
//     MessageUpdateBits<T> messageUpdateBits,
//   ) {
//     return (updates) {
//       final currentValue = readValue() ?? messageUpdateBits.defaultMessage;
//
//       writeValue(
//         messageUpdateBits.rebuildMessage(
//           currentValue,
//           updates,
//         ),
//       );
//     };
//   }
//
//   WriteValue<V?> writeAttribute<V>({
//     required MessageUpdateBits<T> messageUpdateBits,
//     required ScalarAttribute<T, V> scalarAttribute,
//   }) {
//     return ComposedUpdateValue(
//       updateValue: updateMessage(
//         messageUpdateBits,
//       ),
//     ).writeAttribute(
//       scalarAttribute,
//     );
//   }
//
//   HasUpdateValue<V> updateAttribute<V>({
//     required MessageUpdateBits<T> messageUpdateBits,
//     required HasEnsureAttribute<T, V> hasEnsureAttribute,
//   }) {
//     return ComposedUpdateValue(
//       updateValue: updateMessage(
//         messageUpdateBits,
//       ),
//     ).updateAttribute(
//       hasEnsureAttribute,
//     );
//   }
// }

HasWriteValue<F> readWriteValueRebuild<M, F>({
  @ext required ReadWriteValue<M> readWriteValue,
  required HasWriteAttribute<M, F> writeAttribute,
  required RebuildMessage<M> rebuildMessage,
}) {
  return ComposedWriteValue<F>(
    writeValue: (value) => readWriteValue.writeValue(
      rebuildMessage(
        readWriteValue.readValue(),
        (msg) {
          writeAttribute.writeAttribute(
            msg,
            value,
          );
        },
      ),
    ),
  );
}
