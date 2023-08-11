import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';

import 'freezed.dart';

part 'validate.g.has.dart';

// part 'validate.g.compose.dart';

part 'validate.freezed.dart';

sealed class ValidationResult<T> {}

@Has()
typedef ValidationSuccessValue<T> = T;
@Has()
typedef ValidationFailureMessages = List<String>;

abstract class ValidationSuccess<T>
    implements ValidationResult<T>, HasValidationSuccessValue<T> {}

abstract class ValidationFailure<T>
    implements ValidationResult<T>, HasValidationFailureMessages {}

@freezed
class ValidationSuccessImpl<T>
    with _$ValidationSuccessImpl<T>
    implements ValidationSuccess<T> {
  const factory ValidationSuccessImpl(
    ValidationSuccessValue<T> validationSuccessValue,
  ) = _ValidationSuccessImpl;
}

@freezed
class ValidationFailureImpl<T>
    with _$ValidationFailureImpl<T>
    implements ValidationFailure<T> {
  const factory ValidationFailureImpl(
    ValidationFailureMessages validationFailureMessages,
  ) = _ValidationFailureImpl;
}

typedef ValidatingFunction<I, O> = ValidationResult<O> Function(I input);