import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:logger/logger.dart';
import 'package:mhu_dart_commons/io.dart';

import '../file_store.dart';

final _logger = Logger();

Future<FileStore> createFileStoreIO(Directory storeDir) async {
  await storeDir.create(recursive: true);

  _logger.d('Filestore: ${storeDir.path}');

  return FileStoreIO(storeDir: storeDir);
}

class FileStoreIO implements FileStore {
  final Directory storeDir;

  @override
  Future<bool> delete(FilePath path) async {
    final pathStr = path.pathJoin;
    if (await FileSystemEntity.isDirectory(pathStr)) {
      await storeDir.dir(pathStr).delete(recursive: true);
      return true;
    } else if (await FileSystemEntity.isFile(pathStr)) {
      await storeDir.file(pathStr).delete();
      return true;
    }
    return false;
  }

  @override
  Future<bool> exists(FilePath path) {
    final file = storeDir.file(path.pathJoin);
    return file.exists();
  }

  @override
  Future<void> move(FilePath path, XFile xfile) async {
    final sourceFile = File(xfile.path);
    final file = storeDir.file(path.pathJoin);
    await file.parent.create(recursive: true);
    try {
      await sourceFile.rename(file.path);
    } on FileSystemException catch (e) {
      _logger.d(e.message, e);
      await sourceFile.copy(file.path);
    }
  }

  @override
  Future<Uint8List> read(FilePath path) {
    final file = storeDir.file(path.pathJoin);
    return file.readAsBytes();
  }

  @override
  Future<void> write(FilePath path, Uint8List content) async {
    final file = storeDir.file(path.pathJoin);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(content);
  }

  @override
  XFile xfile(FilePath path) {
    return XFile(storeDir.file(path.pathJoin).path);
  }

  const FileStoreIO({
    required this.storeDir,
  });
}
