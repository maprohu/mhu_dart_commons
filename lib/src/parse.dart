import 'package:fixnum/fixnum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'parse.freezed.dart';

typedef ParseFunction<T> = ParseResult<T> Function(String string);

@freezed
sealed class ParseResult<T> with _$ParseResult<T> {
  const factory ParseResult.success({
    required T result,
  }) = ParseSuccess<T>;

  const factory ParseResult.failure({
    required Iterable<String> errors,
  }) = ParseFailure<T>;

  factory ParseResult.fromNullable(
    T? parsed, {
    required String errorMessage,
  }) {
    if (parsed == null) {
      return ParseFailure(
        errors: [errorMessage],
      );
    } else {
      return ParseSuccess(
        result: parsed,
      );
    }
  }
}

extension ParseResultX<T> on ParseResult<T> {
  Iterable<String> get errors => switch (this) {
        ParseSuccess() => const Iterable.empty(),
        ParseFailure(:final errors) => errors,
      };

  T? get orNull {
    switch (this) {
      case ParseFailure():
        return null;
      case ParseSuccess(:final result):
        return result;
    }
  }
}

ParseResult<int> intParseFunction(String string) => ParseResult.fromNullable(
      int.tryParse(string),
      errorMessage: 'Invalid number format.',
    );

ParseResult<Int64> int64ParseFunction(String string) =>
    ParseResult.fromNullable(
      Int64.tryParseInt(string),
      errorMessage: 'Invalid number format.',
    );

ParseResult<double> doubleParseFunction(String string) =>
    ParseResult.fromNullable(
      double.tryParse(
        string.replaceAll(',', '.'),
      ),
      errorMessage: 'Invalid number format.',
    );
