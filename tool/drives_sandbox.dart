import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mhu_dart_commons/commons.dart';
import 'package:mhu_dart_commons/io.dart';
import 'package:rxdart/rxdart.dart';

void main() async {
  Directory("C:").listSync().also(print);
  final drivesWatch = await windowsDrives(disposers: DspImpl());

  drivesWatch.distinctValues().forEach(print);
}

