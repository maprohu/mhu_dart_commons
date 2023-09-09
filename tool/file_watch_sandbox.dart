import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mhu_dart_commons/commons.dart';
import 'package:mhu_dart_commons/io.dart';

import 'package:path/path.dart' as p;

void main() async {
  final dir = Directory.current.dir(".dart_tool/watch").absolute;
  // const events =
  //     FileSystemEvent.create | FileSystemEvent.delete | FileSystemEvent.move;
  // dir
  //     .watch(
  //       events: events,
  //     )
  //     .forEach(print);

  final parts = p.split(r"C:\X\Y");
  final absolutePath = AbsoluteFilePath(
    filePath: parts.toIList(),
  );

  final disposers = DspImpl();
  final listing = await directoryListingWatchPool.acquire(
    absolutePath,
    disposers,
  );

  listing.distinctValues().forEach(print);
}
