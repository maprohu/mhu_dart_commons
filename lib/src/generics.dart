
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';

import 'generics.dart' as $lib;
part 'generics.g.has.dart';
part 'generics.g.dart';


extension MhuGenericsX<T> on T {
  V cast<V>() => this as V;
}

@Has()
typedef TypeGenericFunction<T> = GenericFunction1<T>;

typedef GenericFunction1<T> = R Function<R>(R Function<TT extends T>() fn);

GenericFunction1<B> genericFunction1<B, T extends B>() {
  assert(B != T);
  return <R>(fn) => fn<T>();
}

GenericFunction1<T> genericFunction1Flat<T>() => genericFunction1<T, T>();

String genericFunctionTypeName<T>({
  @ext required GenericFunction1<T> genericFunction,
}) {
  return genericFunction(<TT extends T>() => TT.toString());
}