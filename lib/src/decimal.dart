import 'package:decimal/decimal.dart';
import 'package:mhu_dart_commons/commons.dart';

Decimal? tryParseDecimal(String string) => Decimal.tryParse(
      string.replaceAll(',', '.'),
    );

ParseResult<Decimal> decimalParseFunction(String source) =>
    ParseResult.fromNullable(
      tryParseDecimal(source),
      errorMessage: 'Invalid number format',
    );
