extension MhuMapOfRequiredValueX<K, V extends Object> on Map<K, V> {
  void putOrRemove(K key, V? value) {
    if (value != null) {
      this[key] = value;
    } else {
      remove(key);
    }
  }

  // V? getOpt(K key) => this[key];
  // void setOpt(K key, V? value) {
  //   if (value == null) {
  //     remove(key);
  //   } else {
  //     this[key] = value;
  //   }
  // }
}