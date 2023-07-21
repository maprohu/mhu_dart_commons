import 'dart:math';

String dtbRandomString({
  int length = 20,
  String chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890',
}) {
  final random = Random();
  return List.generate(
    length,
    (index) => chars[random.nextInt(chars.length)],
  ).join();
}
