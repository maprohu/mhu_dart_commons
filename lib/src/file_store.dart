import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'cache.dart';

typedef FileLoader<K> = Future<Uint8List> Function(K path);
typedef FilePathProvider<K> = FilePath Function(K key);

typedef FilePath = IList<String>;

extension FilePathX on FilePath {
  String get pathJoin => join('/');
}

abstract interface class FileStore {
  Future<void> write(
    FilePath path,
    Uint8List content,
  );

  Future<void> move(
    FilePath path,
    XFile xfile,
  );

  Future<Uint8List> read(FilePath path);

  Future<bool> exists(FilePath path);

  Future<bool> delete(FilePath path);

  XFile xfile(FilePath path);
}


FileLoader<K> flcCachedFileLoader<K>({
  required FileLoader<K> loader,
  required FileStore store,
  required FilePath Function(K key) pathProvider,
}) {
  final cache = Cache<K, Future<Future<Uint8List> Function()>>(
    (key) async {
      final path = pathProvider(key);

      if (!await store.exists(path)) {
        final data = await loader(key);
        await store.write(path, data);
      }

      return () => store.read(path);
    },
  );

  return (path) async {
    final fn = await cache.get(path);
    return await fn();
  };
}

