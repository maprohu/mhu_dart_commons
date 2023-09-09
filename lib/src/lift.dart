import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';

import 'lift.dart' as $lib;

part 'lift.g.has.dart';

part 'lift.g.dart';

@Has()
typedef Lower<L, H> = L Function(H high);

@Has()
typedef Higher<L, H> = H Function(L low);

@Compose()
abstract class Lift<L, H> implements HasHigher<L, H>, HasLower<L, H> {}
