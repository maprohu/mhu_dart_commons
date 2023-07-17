import 'package:mhu_dart_commons/src/string.dart';

extension MhuEnumX<T extends Enum> on T {
  String get label => name.camelCaseToLabel;
}
