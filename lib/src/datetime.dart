import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;


String millisSinceEpochToDisplayString(double millisSinceEpoch) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(
    millisSinceEpoch.toInt(),
  );
  final date = DateFormat('y-MM-dd HH:mm').format(dateTime);

  final ago = timeago.format(dateTime);

  return '$date ($ago)';
}