import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mhu_dart_commons/src/stream.dart';

import 'dispose.dart';

extension ServiceStreamOfISetX<K> on Stream<ISet<K>> {
  void runService({
    required Future<void> Function(K key, DspReg disposers) start,
    required DspReg disposers,
  }) {
    final running = <K, DspImpl>{};

    final processDisposers = DspImpl();
    processDiffs(
      added: (item) async {
        final itemDsp = DspImpl();
        running[item] = itemDsp;
        await start(item, itemDsp);
      },
      removed: (item) async {
        final itemDsp = running.remove(item)!;
        await itemDsp.dispose();
      },
      disposers: processDisposers,
    );

    disposers.add(() async {
      await processDisposers.dispose();
      await Future.wait(
        running.values.map(
          (e) => e.dispose(),
        ),
      );
    });
  }
}
