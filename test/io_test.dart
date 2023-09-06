import 'package:mhu_dart_commons/io.dart';
import 'package:test/test.dart';

void main() {
  test("fs root", () async {
    final roots = await fileSystemRoots();

    print(roots.map((e) => e.listSync()));
  });
}