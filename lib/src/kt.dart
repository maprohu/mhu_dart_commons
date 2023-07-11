extension MhuKtAnyX<T> on T {
  R let<R>(R Function(T e) fn) => fn(this);

}