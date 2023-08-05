import 'dart:io';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:path/path.dart' as path;

import '../file_store.dart';

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