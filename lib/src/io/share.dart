import 'dart:io';
import 'dart:typed_data';

import 'filesystem.dart';
import '../random.dart';

const _shareFileDirName = 'mhu_dart_commons_share_file';

late final Directory _cacheDir;

void initShareDirectory(Directory dir) {
  _cacheDir = dir;
}

final _shareFileDir = () async {
  return _cacheDir.dir(_shareFileDirName);
}();

final _cleanAtStartup = () async {
  final dir = await _shareFileDir;

  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }

  return dir;
}();

Future<File> sharableFile({
  required Uint8List bytes,
  required String name,
}) async {
  final base = await _cleanAtStartup;

  final dir = base.dir(dtbRandomString());
  await dir.create(recursive: true);

  final file = dir.file(name);
  await file.writeAsBytes(bytes);

  return file;
}

Future<File> sharableFileCopy({
  required String uuid,
  required File file,
  required String name,
}) async {
  final base = await _cleanAtStartup;

  final dir = base.dir(uuid);
  await dir.create(recursive: true);

  final copy = dir.file(name);

  if (!(await copy.exists())) {
    await file.copy(copy.path);
  }

  return copy;
}
