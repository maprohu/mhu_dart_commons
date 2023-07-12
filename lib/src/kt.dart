extension MhuKtAnyX<T> on T {
  R let<R>(R Function(T e) fn) => fn(this);

  T also(void Function(T e) fn) {
    fn(this);
    return this;
  }
}

T run<T>(T Function() fn) => fn();