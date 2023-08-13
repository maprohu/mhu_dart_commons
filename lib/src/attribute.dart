import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';

part 'attribute.g.has.dart';

part 'attribute.g.compose.dart';

@Has()
typedef ReadAttribute<O, A> = A Function(O object);
@Has()
typedef WriteAttribute<O, A> = void Function(O object, A attribute);
@Has()
typedef EnsureAttribute<O, A> = A Function(O object);

@Has()
typedef ClearAttribute<O> = void Function(O object);

@Has()
typedef ExistsAttribute<O> = bool Function(O object);

@Compose()
abstract class ReadOnlyAttribute<O, A> implements HasReadAttribute<O, A> {}

@Compose()
abstract class ReadEnsureAttribute<O, A>
    implements ReadOnlyAttribute<O, A>, HasEnsureAttribute<O, A> {}

@Compose()
abstract class ReadWriteAttribute<O, A>
    implements ReadOnlyAttribute<O, A>, HasWriteAttribute<O, A> {}

@Compose()
abstract class ScalarAttribute<O, A>
    implements
        ReadWriteAttribute<O, A>,
        HasClearAttribute<O>,
        HasExistsAttribute<O> {}

@Compose()
abstract class MessageAttribute<O, A>
    implements ScalarAttribute<O, A>, ReadEnsureAttribute<O, A> {}

extension HasReadAttributeX<O, A> on HasReadAttribute<O, A> {
  ReadOnlyAttribute<O, B> thenRead<B>(
    HasReadAttribute<A, B> hasReadAttribute,
  ) {
    return ComposedReadOnlyAttribute(
      readAttribute: (object) => hasReadAttribute.readAttribute(
        readAttribute(object),
      ),
    );
  }
}

extension HasEnsureAttributeX<O, A> on ReadEnsureAttribute<O, A> {
  ReadWriteAttribute<O, B> thenReadWrite<B>(
    ReadWriteAttribute<A, B> readWriteAttribute,
  ) {
    return ComposedReadWriteAttribute.readOnlyAttribute(
      readOnlyAttribute: thenRead(readWriteAttribute),
      writeAttribute: (object, attribute) {
        readWriteAttribute.writeAttribute(
          ensureAttribute(object),
          attribute,
        );
      },
    );
  }

  ReadEnsureAttribute<O, B> thenReadEnsure<B>(
    ReadEnsureAttribute<A, B> readEnsureAttribute,
  ) {
    return ComposedReadEnsureAttribute.readOnlyAttribute(
      readOnlyAttribute: thenRead(readEnsureAttribute),
      ensureAttribute: (object) {
        return readEnsureAttribute.ensureAttribute(
          ensureAttribute(object),
        );
      },
    );
  }
}
