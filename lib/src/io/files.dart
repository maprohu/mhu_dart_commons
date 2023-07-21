import 'dart:async';
import 'dart:io';

typedef FileUse = Future<R> Function<R>(FutureOr<R> Function(File file) action);

Future<T> finallyDelete<T>({
  required File file,
  required FutureOr<T> Function(FileUse useFile) action,
}) async {
  int count = 1;
  void acquire() {
    assert(count > 0);
    count++;
  }

  Future<void> release() async {
    assert(count > 0);
    count--;
    if (count == 0) {
      await file.delete();
    }
  }

  try {
    return await action(<R>(action) async {
      acquire();
      try {
        return await action(file);
      } finally {
        await release();
      }
    });
  } finally {
    await release();
  }
}
