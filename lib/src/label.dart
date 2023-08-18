import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';

part 'label.g.has.dart';
// part 'label.g.compose.dart';

@Has()
typedef Label = String;

@Has()
typedef WatchLabel = WatchValue<Label>;