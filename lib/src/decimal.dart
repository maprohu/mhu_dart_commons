import 'package:decimal/decimal.dart';

Decimal? tryParseDecimal(String string) => Decimal.tryParse(
  string.replaceAll(',', '.'),
);