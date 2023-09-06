import 'dart:convert';
import 'dart:io';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';
import 'package:mhu_dart_commons/io.dart';
import 'package:path/path.dart' as path;

import '../file_store.dart';

import 'filesystem.dart' as $lib;

part 'filesystem.g.has.dart';

part 'filesystem.g.dart';

part 'filesystem/async_tree.dart';

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
  FilePath get filePath => path.split(this.path).toIList();

  String get name => filePath.last;
}

extension MhuFileX on File {
  String get filename => filePath.last;
}

Future<ListingNode> fileSystemRoots() async {
  if (Platform.isWindows) {
    final rootsLines = await Directory.current.runAsString(
      "powershell",
      [
        '-Command',
        'Get-PSDrive -PSProvider FileSystem | Select -ExpandProperty "Root"',
      ],
    );
    return ComposedRootsNode(
      fileSystemRoots: const LineSplitter()
          .convert(rootsLines)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map(Directory.new)
          .toIList(),
    );
  } else {
    return ComposedDirectoryNode(
      iODirectory: Directory("/"),
    );
  }
}
