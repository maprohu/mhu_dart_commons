import 'package:mhu_dart_commons/commons.dart';
import 'package:test/test.dart';


void main() {

  test("allEqual", () {
    expect([1, 1].allEqual, true);
    expect([1, 2].allEqual, false);


    expect([0.1, 0.1].allRoughlyEqual(), true);
    expect([0.0001, 0.0002].allRoughlyEqual(), true);
    expect([0.2, 0.1].allRoughlyEqual(), false);
  });
}
