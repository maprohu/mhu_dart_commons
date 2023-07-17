class RequiredProp<T extends Object> {
  final T Function() _get;
  final void Function(T value) _set;

  const RequiredProp({
    required T Function() get,
    required void Function(T value) set,
  })  : _get = get,
        _set = set;

  T get value => _get();

  set value(T value) => _set(value);

  void set(T message) => value = message;

  T get() => value;
}
