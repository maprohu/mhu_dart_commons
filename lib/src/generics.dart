extension MhuGenericsX<T> on T {
  V cast<V>() => this as V;
}

typedef GenericFunction1<T> = R Function<R>(R Function<TT extends T>() fn);

GenericFunction1<B> genericFunction1<B, T extends B>() {
  assert(B != T);
  return <R>(fn) => fn<T>();
}

GenericFunction1<T> genericFunction1Flat<T>() => genericFunction1<T, T>();
