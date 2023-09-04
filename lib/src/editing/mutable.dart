part of '../editing.dart';

extension MutableValueX<T> on MutableValue<T> {
  MutableValue<V> mutableAttribute<V>(
      MutableAttribute<T, V> mutableAttribute,
      ) {
    return ComposedMutableValue.readWatchValue(
      readWatchValue: readWatchAttribute(mutableAttribute),
      updateValue: updateAttribute(mutableAttribute).updateValue,
    );
  }

  SingleValue<V> scalarAttribute<V>(
      ScalarAttribute<T, V> scalarAttribute,
      ) {
    return ComposedSingleValue.readWatchValue(
      readWatchValue: readWatchAttribute(
        scalarAttribute,
      ),
      writeValue: writeAttribute(
        scalarAttribute,
      ),
    );
  }
}
