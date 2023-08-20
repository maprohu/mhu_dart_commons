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

  test("infinite iterable", () {
    const count = 1000000;
    final sw = Stopwatch()..start();
    expect(
      Iterable.generate(count).length,
      count,
    );
    print(sw.elapsed);
    sw.reset();
    expect(
      0.infiniteIterable((item) => item).take(count).length,
      count,
    );
    print(sw.elapsed);
  });

  test("zip2", () {
    final lefts = [0, 1];
    final rights = ["a", "b", "c"];

    final zipped = zip2Iterables(lefts, rights).toList();

    expect(zipped.length, 3);
  });
}
