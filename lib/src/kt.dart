extension MhuKtAnyX<T> on T {
  R let<R>(R Function(T e) fn) => fn(this);

  T also(void Function(T e) fn) {
    fn(this);
    return this;
  }

  @pragma('vm:prefer-inline')
  T? takeIf(bool Function(T) predicate) {
    if (predicate(this)) return this;
    return null;
  }
}

T run<T>(T Function() fn) => fn();