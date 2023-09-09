@HasOf<Directory>()
@HasOf<File>()
@HasOf<FileSystemEntity>()
@HasOf<Link>()
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';
import 'package:path/path.dart' as path;
import 'package:rxdart/rxdart.dart';

import 'filesystem.dart' as $lib;

part 'filesystem.g.has.dart';

part 'filesystem.g.dart';

// part 'filesystem/async_tree.dart';
part 'filesystem/root.dart';

part 'filesystem/watch.dart';

part 'filesystem.freezed.dart';

Future<DirectoryListing> directoryListing({
  @ext required Directory directory,
}) async {
  final entities = await directory.list(followLinks: false).toList();
  final entries = entities.map(
    (e) {
      return DirectoryEntry(
        name: e.fileSystemEntityName(),
        type: switch (e) {
          Directory() => DirectoryEntryType.directory,
          File() => DirectoryEntryType.file,
          _ => DirectoryEntryType.other,
        },
      );
    },
  ).toList()
    ..sort(directoryEntryCompare);
  return DirectoryListing(
    entries: entries.toIList(),
  );
}

extension MhuDirectoryX on Directory {
  Directory dir(String name) => dirTo([name]);

  Directory dirTo(List<String> name) {
    return Directory(
      path.joinAll([this.path, ...name]),
    );
  }

  File file(String name) => fileTo([name]);

  File fileTo(List<String> name) {
    return File(
      path.joinAll([this.path, ...name]),
    );
  }
}

extension MhuFileSystemEntityX on FileSystemEntity {
  @Deprecated("use fileSystemEntityPath")
  FilePath get filePath => path.split(this.path).toIList();

  @Deprecated("use fileSystemEntityName")
  String get name => filePath.last;
}

extension MhuFileX on File {
  String get filename => filePath.last;
}

@Has()
typedef RootDirectory = Directory;

@Has()
typedef DiskDriveList = IList<Directory>;

@Has()
typedef WatchDiskDriveList = WatchReload<DiskDriveList>;

// sealed class FileSystemRoots {}
//
// @Compose()
// abstract class SingleFileSystemRoot
//     implements FileSystemRoots, HasRootDirectory {}
//
// @Compose()
// abstract class FileSystemRootDrives
//     implements FileSystemRoots, HasWatchDiskDriveList {}
//
// Future<FileSystemRoots> fileSystemRoots() async {
//   if (Platform.isWindows) {
//     Future<DiskDriveList> loadDrives() async {
//       final rootsLines = await Directory.current.runAsString(
//         "powershell",
//         [
//           '-Command',
//           'Get-PSDrive -PSProvider FileSystem | Select -ExpandProperty "Root"',
//         ],
//       );
//       return const LineSplitter()
//           .convert(rootsLines)
//           .map((e) => e.trim())
//           .where((e) => e.isNotEmpty)
//           .map(Directory.new)
//           .toIList();
//     }
//
//     // TODO implement watch
//     return ComposedFileSystemRootDrives(
//       watchDiskDriveList: await watchReloadAsync(
//         loadValue: loadDrives,
//       ),
//     );
//   } else {
//     return ComposedSingleFileSystemRoot(
//       rootDirectory: Directory("/"),
//     );
//   }
// }

sealed class FileSystemEntityNode implements HasName {}

@Compose()
abstract class DirectoryNode implements FileSystemEntityNode, HasDirectory {}

sealed class FileSystemLeafNode implements FileSystemEntityNode {}

@Compose()
abstract class FileNode implements FileSystemLeafNode, HasFile {}

@Compose()
abstract class LinkNode implements FileSystemLeafNode, HasLink {}

FilePath fileSystemEntityPath({
  @ext required FileSystemEntity fileSystemEntity,
}) {
  return path.split(fileSystemEntity.path).toIList();
}

FilePathElement fileSystemEntityName({
  @ext required FileSystemEntity fileSystemEntity,
}) {
  return fileSystemEntity.fileSystemEntityPath().last;
}

FileSystemEntityNode createFileSystemEntityNode({
  @ext required FileSystemEntity fileSystemEntity,
}) {
  switch (fileSystemEntity) {
    case Directory():
      return fileSystemEntity.directoryNode();
    case File():
      return ComposedFileNode(
        name: fileSystemEntity.fileSystemEntityName(),
        file: fileSystemEntity,
      );
    case Link():
      return ComposedLinkNode(
        name: fileSystemEntity.fileSystemEntityName(),
        link: fileSystemEntity,
      );
    default:
      throw fileSystemEntity;
  }
}

Future<List<FileSystemEntityNode>> listDirectoryNodes({
  @extHas required Directory directory,
}) async {
  return await directory
      .list()
      .map((e) => e.createFileSystemEntityNode())
      .toList();
}

DirectoryNode directoryNode({
  @ext required Directory directory,
}) {
  return ComposedDirectoryNode(
    name: directory.fileSystemEntityName(),
    directory: directory,
  );
}

// CancelableOperation<DirectoryListing> fileSystemRootsWatchReloadNodes({
//   @ext required FileSystemRoots fileSystemRoots,
//   required DspReg disposers,
// }) {
//   switch (fileSystemRoots) {
//     case FileSystemRootDrives():
//       final drives = fileSystemRoots.watchDiskDriveList;
//       return ComposedWatchReload(
//         watchValue: () {
//           return drives.watchValue().map((d) => d.directoryNode()).toIList();
//         },
//         reloader: drives.reloader,
//       ).constantCancelableOperation();
//     case SingleFileSystemRoot():
//       return fileSystemRoots.rootDirectory.directoryWatchReloadNodes(
//         disposers: disposers,
//       );
//   }
// }

// CancelableOperation<FileSystemEntityLoader> absolutePathLoader({
//   @ext required AbsoluteFilePath absoluteFilePath,
//   required DspReg disposers,
// }) {
//   return CancelableOperation.fromFuture(
//     absoluteFilePath.loadAbsolutePath(),
//   ).then(
//         (nodes) async {
//       final nodesVar = watchVar(nodes);
//
//       final executorDisposers = DspImpl();
//       final executor = LatestExecutor<void>(
//         process: (_) async {
//           nodesVar.value = await absoluteFilePath.loadAbsolutePath();
//         },
//         disposers: executorDisposers,
//       );
//
//       // final listening = directory.watch().listen(executor.submit);
//
//       // disposers.add(() async {
//       //   await listening.cancel();
//       //   await executorDisposers.dispose();
//       // });
//
//       return watchReloadSync(
//         readWatchValue: nodesVar,
//         createDirtyChecker: equalsDirtyChecker,
//       );
//     },
//   );
// }

// String joinAbsolutePath({
//   @ext required AbsoluteFilePath absoluteFilePath,
// }) {
//   return path.joinAll(absoluteFilePath.filePath);
// }

// Future<LoadedFileSystemEntity> loadAbsolutePath({
//   @ext required AbsoluteFilePath absoluteFilePath,
// }) async {
//   final pathString = absoluteFilePath.joinAbsolutePath();
//   final type = await FileSystemEntity.type(pathString);
//
//   switch (type) {
//     case FileSystemEntityType.file:
//       return LoadedFile();
//     case FileSystemEntityType.link:
//       return LoadedLink();
//     case FileSystemEntityType.directory:
//       return LoadedListing(
//         listing: await Directory(pathString).directoryListing(),
//       );
//     default:
//       return LoadedNotFound();
//   }
// }

sealed class LoadedFileSystemEntity {}

class LoadedNotFound implements LoadedFileSystemEntity {
  const LoadedNotFound();
}

class LoadedFile implements LoadedFileSystemEntity {
  const LoadedFile();
}

class LoadedLink implements LoadedFileSystemEntity {
  const LoadedLink();
}

@freezed
class LoadedListing with _$LoadedListing implements LoadedFileSystemEntity {
  const factory LoadedListing({
    required DirectoryListing listing,
  }) = _LoadedListing;
}

typedef FileSystemEntityLoader = WatchReload<LoadedFileSystemEntity>;

// CancelableOperation<FileSystemEntityLoader> fileSystemEntityLoader({
//   required AbsoluteFilePath absoluteFilePath,
// }) {
//   final filePath = absoluteFilePath.filePath;
//
//   if (filePath.isEmpty) {
//     // fileSystemRoots().
//   } else {}
// }

// RefCountPool<Ab> directoryChangePool() {
//   Directory.current.watch();
// }
