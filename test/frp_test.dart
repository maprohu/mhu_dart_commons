import 'package:mhu_dart_commons/commons.dart';
import 'package:test/test.dart';

void main() {
  test("frp update once", () async {
    final a = fw(1);
    final b = fr(() => a());
    final c = fr(() => -a());

    final disposers = DspImpl();
    final result = disposers.fr(() {
      return b() + c();
    });

    final resultListFuture = result.changes().toList();
    a.value = 2;

    await disposers.dispose();

    final resultList = await resultListFuture;

    expect(resultList, [0]);
    expect(b.read(), 2);
  });

  test(
    "fr changes first",
    () async {
      final frw = fw(0);

      final disposers = DspImpl();
      final frr = disposers.fr(() => frw());

      final changesList = frr.changes().toList();

      disposers.dispose();

      expect(await changesList, [0]);
    },
  );
}
