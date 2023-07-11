extension MhuMapOfRequiredValueX<K, V extends Object> on Map<K, V> {
  void putOrRemove(K key, V? value) {
    if (value != null) {
      this[key] = value;
    } else {
      remove(key);
    }
  }
}