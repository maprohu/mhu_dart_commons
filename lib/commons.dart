
class MhuException implements Exception {
  final String message;

  MhuException(this.message);

  @override
  String toString() {
    return '$runtimeType: $message';
  }
}