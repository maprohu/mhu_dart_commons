import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';

part 'interfaces.g.has.dart';

abstract class HasPayload<T> {
  T get payload;
}

extension HasPayloadX<T> on Iterable<HasPayload<T>> {
  Iterable<T> get payloads => map((e) => e.payload);
}


@Has()
typedef Name = String;

typedef TypeFunction<TF> = R Function<R>(R Function<T extends TF>() fn);

extension TypeFunctionX<TF> on TypeFunction<TF> {
  Type get get => this(<R extends TF>() => R);
}

abstract interface class HasThisType {
  R thisType$<R>(R Function<TF>() fn);
}
