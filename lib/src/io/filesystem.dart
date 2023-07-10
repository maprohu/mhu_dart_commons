import 'dart:io';

extension MhuDirectoryX on Directory {
  Directory dir(String name) => Directory.fromUri(
        uri.resolve(name),
      );

  File file(String name) => File.fromUri(
        uri.resolve(name),
      );
}
