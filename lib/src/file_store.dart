import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:cross_file/cross_file.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'cache.dart';
import 'collection/compare.dart';
import 'dispose.dart';
import 'freezed.dart';

import 'file_store.dart' as $lib;
import 'watch.dart';

part 'file_store.g.has.dart';

part 'file_store.g.dart';

part 'file_store.freezed.dart';

typedef FileLoader<K> = Future<Uint8List> Function(K path);
typedef FilePathProvider<K> = FilePath Function(K key);

typedef FilePathElement = String;

@Has()
typedef FilePath = IList<FilePathElement>;

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

@freezed
class AbsoluteFilePath with _$AbsoluteFilePath implements HasFilePath {
  const factory AbsoluteFilePath({
    required FilePath filePath,
  }) = _AbsoluteFilePath;

  static final root = AbsoluteFilePath(
    filePath: IList(),
  );
}

AbsoluteFilePath absolutePathChild({
  @ext required AbsoluteFilePath absoluteFilePath,
  required FilePathElement pathElement,
}) {
  return AbsoluteFilePath(
    filePath: absoluteFilePath.filePath.add(pathElement),
  );
}

AbsoluteFilePath absolutePathParent({
  @ext required AbsoluteFilePath absoluteFilePath,
}) {
  assert(!absoluteFilePath.absolutePathIsRoot());
  return AbsoluteFilePath(
    filePath: absoluteFilePath.filePath.removeLast(),
  );
}

bool absolutePathIsRoot({
  @ext required AbsoluteFilePath absoluteFilePath,
}) {
  return absoluteFilePath.filePath.isEmpty;
}

@Has()
typedef JoinAbsolutePath = String Function(AbsoluteFilePath absoluteFilePath);

String joinAbsolutePathString({
  @ext required AbsoluteFilePath absoluteFilePath,
  required HasJoinAbsolutePath fileSystemRootActions,
}) {
  return fileSystemRootActions.joinAbsolutePath(absoluteFilePath);
}

@Has()
@freezed
class DirectoryListing with _$DirectoryListing {
  @Assert("entries.isSorted(directoryEntryCompare)")
  factory DirectoryListing({
    required IList<DirectoryEntry> entries,
  }) = _DirectoryListing;

  static final empty = DirectoryListing(
    entries: IList(),
  );
}

@freezed
class DirectoryEntry with _$DirectoryEntry {
  const factory DirectoryEntry({
    required FilePathElement name,
    required DirectoryEntryType type,
  }) = _DirectoryEntry;
}

int directoryEntryCompare(
  DirectoryEntry a,
  DirectoryEntry b,
) {
  return a.name.compareTo(b.name);
}

enum DirectoryEntryType {
  file,
  directory,
  other,
}

typedef DirectoryListingWatch = WatchRead<DirectoryListing?>;

// sealed class FileSystemPathState {
//   const FileSystemPathState();
//
//   static const FileSystemPathState directory = DirectoryState._();
//   static const FileSystemPathState other = OtherFileSystemPathState._();
// }
//
// class FileState extends FileSystemPathState {
//   const FileState._();
// }
// class DirectoryState extends FileSystemPathState {
//   const DirectoryState._();
// }
//
// class OtherFileSystemPathState extends FileSystemPathState {
//   const OtherFileSystemPathState._();
// }

typedef FileSystemPathWatch = WatchRead<DirectoryEntryType>;

final fileSystemRootPathWatch = watchVar(DirectoryEntryType.directory);

@Has()
typedef FileSystemPathWatchPool
    = RefCountPool<AbsoluteFilePath, FileSystemPathWatch>;

@Has()
typedef DirectoryListingWatchPool
    = RefCountPool<AbsoluteFilePath, DirectoryListingWatch>;

DirectoryEntry? directoryListingFindEntry({
  @ext required DirectoryListing directoryListing,
  required FilePathElement name,
}) {
  final findEntry = DirectoryEntry(
    name: name,
    type: DirectoryEntryType.other,
  );

  final list = directoryListing.entries.unlockView;

  final foundIndex = binarySearch(
    list,
    findEntry,
    compare: directoryEntryCompare,
  );

  if (foundIndex < 0) {
    return null;
  } else {
    return list[foundIndex];
  }
}
