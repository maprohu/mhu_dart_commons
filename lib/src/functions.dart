import 'dart:async';

import 'package:async/async.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';

import 'functions.dart' as $lib;
// part 'functions.g.has.dart';

part 'functions.g.dart';

part 'functions/drain.dart';
part 'functions/convert.dart';

T identity<T>(T value) => value;

void ignore0() {}

void noop() {}

void ignore1(dynamic p0) {}

Never throws0() => throw UnimplementedError();

Never throws1(dynamic p0) => throw UnimplementedError();

Iterable<T> empty0<T>() => Iterable.empty();

Iterable<T> empty1<T>(dynamic p0) => Iterable.empty();

bool constantFalse() => false;

extension CallbackX<T> on void Function(T) {
  void Function(T) skip(int count) {
    assert(count >= 0);

    int counter = count;

    return (value) {
      if (counter == 0) {
        call(value);
      } else {
        counter--;
      }
    };
  }

  set value(T value) {
    this(value);
  }
}

extension AsyncCallbackX<T> on Future<void> Function(T value) {
  void Function(T value) get discardWhenBusy {
    var working = false;

    return (value) async {
      if (working) return;
      working = true;
      await this(value);
      working = false;
    };
  }
}

typedef Call<T> = T Function();
typedef CallDsp<T> = T Function(DspReg disposers);
typedef AsyncCall<T> = Call<Future<T>>;
typedef AsyncCallDsp<T> = CallDsp<Future<T>>;
typedef CancelableCall<T> = Call<CancelableOperation<T>>;
typedef CancelableCallDsp<T> = CallDsp<CancelableOperation<T>>;

typedef VoidCall = Call<void>;
typedef AsyncVoidCall = AsyncCall<void>;


typedef Callback<T> = void Function(T value);

typedef Execute = T Function<T>(T Function() action);


extension CallAnyX<T> on T {
  Call<T> get toCall => () => this;
}

Call<T> callOf<T>(T value) => value.toCall;

Call<T> constantCall<T>(
  @ext T value,
) {
  return () => value;
}

typedef Lookup<K, V> = V Function(K key);

CancelableOperation<T> cancelableOperation<T extends Object>(
  Future<T?> Function(Call<bool> canceled) builder,
) {
  final completer = Completer<T>();

  var canceled = false;
  () async {
    try {
      final result = await builder(() => canceled);
      if (result != null) {
        completer.complete(result);
      }
    } catch (e) {
      completer.completeError(e);
    }
  }();

  return CancelableOperation.fromFuture(
    completer.future,
    onCancel: () => canceled = true,
  );
}

VoidCall once(VoidCall call) {
  late final value = call();
  return () => value;
}

C Function(A a) functionComposition<A, B, C>({
  @ext required B Function(A a) aToB,
  required C Function(B b) bToC,
}) {
  return (a) => bToC(aToB(a));
}
