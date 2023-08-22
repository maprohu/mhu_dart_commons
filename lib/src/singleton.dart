import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';

import 'singleton.dart' as $lib;

part 'singleton.g.dart';

part 'singleton.g.has.dart';

part 'singleton.g.compose.dart';

@Has()
typedef SingletonsByKey<K, V> = IMap<K, V>;
@Has()
typedef SingletonsByType<V> = Map<Type, V>;

@Compose()
abstract class Singletons<K, V>
    implements HasSingletonsByKey<K, V>, HasSingletonsByType<V> {
  static Singletons<K, V> create<K, V>({
    required Map<K, V> singletonsByKey,
    required WriteAttribute<V, K> setKey,
  }) {
    final SingletonsByType<V> singletonsByType = {};
    for (final value in singletonsByKey.values) {
      final type = value.runtimeType;
      assert(!singletonsByType.containsKey(type), value);
      singletonsByType[type] = value;
    }
    for (final MapEntry(:key, :value) in singletonsByKey.entries) {
      setKey(value, key);
    }
    return ComposedSingletons(
      singletonsByKey: singletonsByKey.toIMap(),
      singletonsByType: singletonsByType,
    );
  }

  static Singletons<K, V> mixin<K, V extends MixSingletonKey<K>>(
    Map<K, V> singletonsByKey,
  ) =>
      create(
        singletonsByKey: singletonsByKey,
        setKey: (object, attribute) {
          object.singletonKey = attribute;
        },
      );

  static Singletons<K, V> holder<K, V extends HasSingletonKeyHolder<K>>(
    Map<K, V> singletonsByKey,
  ) =>
      create(
        singletonsByKey: singletonsByKey,
        setKey: setSingletonKey,
      );
}

@Has()
typedef SingletonKey<K> = K;

@Has()
typedef SingletonKeyHolder<K> = LateFinal<K>;

K getSingletonKey<K>({
  @Ext() required HasSingletonKeyHolder<K> hasSingletonKeyHolder,
}) {
  return hasSingletonKeyHolder.singletonKeyHolder.value;
}

void setSingletonKey<K>(
  @Ext() HasSingletonKeyHolder<K> hasSingletonKeyHolder,
  K singletonKey,
) {
  hasSingletonKeyHolder.singletonKeyHolder.value = singletonKey;
}

W lookupSingletonByType<K, V, W extends V>({
  @Ext() required Singletons<K, V> singletons,
}) {
  return singletons.singletonsByType.putIfAbsent(W, () {
    return singletons.singletonsByKey.values.singleWhere((e) => e is W);
  }) as W;
}
