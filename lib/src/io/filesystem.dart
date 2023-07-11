import 'dart:io';
import 'package:path/path.dart' as path;

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
