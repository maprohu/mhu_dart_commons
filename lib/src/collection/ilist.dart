import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';

import 'ilist.dart' as $lib;

// part 'ilist.g.has.dart';
part 'ilist.g.dart';

Iterable<T> reversedIListIterable<T>({
  @Ext() required IList<T> list,
}) {
  return list.unlockView.reversed;
}

