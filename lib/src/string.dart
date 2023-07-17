extension MhuStringX on String {
  String capitalize() {
    return isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
  }

  String uncapitalize() {
    return isEmpty ? this : "${this[0].toLowerCase()}${substring(1)}";
  }

  String get paren => '($this)';

  String get camelCaseToLabel {
    RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    return capitalize().replaceAllMapped(
      exp,
      (Match m) => ' ${m.group(0)!}',
    );
  }
}
