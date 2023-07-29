import 'package:mhu_dart_commons/commons.dart';
import 'package:test/test.dart';

extension BoolX on bool {
  void get mustBeTrue => expect(this, true);
}

void main() {
  final int? nullInt = null;
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final int? one = 1;

  test("nullFirst", () {
    final cmp = nullFirst(compareTo<num>);

    nullInt.equalTo(nullInt, comparator: cmp).mustBeTrue;
    nullInt.lessThan(one, comparator: cmp).mustBeTrue;
    one.greaterThan(nullInt, comparator: cmp).mustBeTrue;
    1.lessThan(2, comparator: cmp).mustBeTrue;
    2.greaterThan(1, comparator: cmp).mustBeTrue;
    one.equalTo(one, comparator: cmp).mustBeTrue;
  });

  test("nullLast", () {
    final cmp = nullLast(compareTo<num>);

    nullInt.greaterThan(one, comparator: cmp).mustBeTrue;
    one.lessThan(nullInt, comparator: cmp).mustBeTrue;
    1.lessThan(2, comparator: cmp).mustBeTrue;
    2.greaterThan(1, comparator: cmp).mustBeTrue;
    nullInt.equalTo(nullInt, comparator: cmp).mustBeTrue;
    one.equalTo(one, comparator: cmp).mustBeTrue;
  });

  test("iterable compare", () {
    expect(
      iterableCompare<num>([], []),
      0,
    );
    expect(
      iterableCompare<num>([1], [1]),
      0,
    );
    expect(
      iterableCompare<num>([0], [1]),
      -1,
    );
    expect(
      iterableCompare<num>([1], [0]),
      1,
    );
    expect(
      iterableCompare<num>([0, 0], [0]),
      1,
    );
    expect(
      iterableCompare<num>([0], [0, 0]),
      -1,
    );
    expect(
      iterableCompare<num>([0, 1], [0, 0]),
      1,
    );
  });
}
