abstract class HasPayload<T> {
  T get payload;
}

extension HasPayloadX<T> on Iterable<HasPayload<T>> {
  Iterable<T> get payloads => map((e) => e.payload);
}

abstract class HasName {
  String get name;
}
abstract interface class HasThisType {
  R thisType$<R>(R Function<TF>() fn);
}
