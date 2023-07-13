import 'dart:async';
import 'dart:io';

class ScreenshotParams {
  static const host = 'SCREENSHOT_HOST';
  static const port = 'SCREENSHOT_PORT';
}

class ScreenshotMessages {
  static const done = '<done>';
  static const quit = '<quit>';
}

class ScreenshotsFlutter {
  static const screenshotHost = String.fromEnvironment(ScreenshotParams.host);
  static const screenshotPort = int.fromEnvironment(ScreenshotParams.port);

  static const remote = "$screenshotHost:$screenshotPort";

  final Socket socket;
  Completer? _completer;

  ScreenshotsFlutter(this.socket) {
    socket.listen((event) {
      final msg = String.fromCharCodes(event);
      assert(msg == ScreenshotMessages.done);
      _completer!.complete();
      _completer = null;
    });
  }

  Future<void> _waitAck() {
    assert(_completer == null);
    final comp = Completer();
    _completer = comp;
    return comp.future;
  }

  Future<void> _send(String msg) async {
    final ack = _waitAck();
    socket.write(msg);
    await socket.flush();
    await ack;
  }

  Future<void> take(String name) async {
    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );
    await _send(name);
  }

  void shutdown() {
    _send(ScreenshotMessages.quit);
  }

  static Future<ScreenshotsFlutter> create() async {
    final Socket socket = await Socket.connect(screenshotHost, screenshotPort);

    return ScreenshotsFlutter(socket);
  }
}
