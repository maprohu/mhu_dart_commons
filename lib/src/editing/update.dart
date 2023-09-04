part of '../editing.dart';

extension HasUpdateValueX<T> on HasUpdateValue<T> {
  WriteValue<V?> writeAttribute<V>(
      ScalarAttribute<T, V> scalarAttribute,
      ) {
    return (value) {
      updateValue(
            (message) {
          if (value == null) {
            scalarAttribute.clearAttribute(message);
          } else {
            scalarAttribute.writeAttribute(message, value);
          }
        },
      );
    };
  }

  HasUpdateValue<V> updateAttribute<V>(
      HasEnsureAttribute<T, V> hasEnsureAttribute,
      ) {
    return ComposedUpdateValue(
      updateValue: (updates) {
        updateValue(
              (value) {
            updates(
              hasEnsureAttribute.ensureAttribute(
                value,
              ),
            );
          },
        );
      },
    );
  }
}
