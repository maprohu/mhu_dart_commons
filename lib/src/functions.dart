T identity<T>(T value) => value;

void ignore1(dynamic p0) {}
Never throws0() => throw UnimplementedError();
Never throws1(dynamic p0) => throw UnimplementedError();

Iterable<T> empty0<T>() => Iterable.empty();
Iterable<T> empty1<T>(dynamic p0) => Iterable.empty();

extension CallbackX<T> on void Function(T) {
  void Function(T) skip(int count) {
    assert (count >= 0);

    int counter = count;

    return (value) {
      if (counter == 0) {
        call(value);
      } else {
        counter--;
      }
    };
  }

  set value(T value)  {
    this(value);
  }
}
