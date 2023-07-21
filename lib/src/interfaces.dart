
abstract class HasPayload<T> {
  T get payload;
}

extension HasPayloadX<T> on Iterable<HasPayload<T>> {
  Iterable<T> get payloads => map((e) => e.payload);
}

abstract class HasName {
  String get name;
}

typedef TypeFunction<TF> = R Function<R>(R Function<T extends TF>() fn);

extension TypeFunctionX<TF> on TypeFunction<TF> {
  Type get get => this(<R extends TF>() => R);
}

abstract interface class HasThisType {
  R thisType$<R>(R Function<TF>() fn);
}
