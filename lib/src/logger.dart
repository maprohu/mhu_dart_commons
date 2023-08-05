import 'package:logger/logger.dart';

class MhuLogger {
  static const errorMethodCount = 16;

  static final printer = PrettyPrinter(
    errorMethodCount: errorMethodCount,
  );

  static final logger = Logger(printer: printer);
  static final cut1 = Logger(
    printer: PrettyPrinter(
      errorMethodCount: errorMethodCount,
      stackTraceBeginIndex: 1,
    ),
  );
}

final logger = MhuLogger.logger;
