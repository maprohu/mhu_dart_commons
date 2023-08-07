import 'package:mhu_dart_commons/commons.dart';
import 'package:test/test.dart';

void main() {
  test("string slices", () {
    final string = "abcdefg";

    expect(string.slices(2), ["ab", "cd", "ef", "g"]);

    expect("".slices(10), []);
  });
}
