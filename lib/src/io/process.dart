import 'dart:convert';
import 'dart:io';

extension MhuProcecessDirectoryX on Directory {
  Future run(
    String executable,
    List<String> arguments, {
    String? errorMessage,
  }) async {
    await startProcess(
      executable,
      arguments,
    ).join(
      errorMessage: errorMessage ??
          "Error running command: $executable ${arguments.join(' ')}",
    );
  }

  Future<Process> startProcess(
    String executable,
    List<String> arguments,
  ) {
    stdout.writeln('Starting process: $executable ${arguments.join(' ')}');
    return Process.start(
      executable,
      arguments,
      workingDirectory: this == Directory.current ? null : path,
      mode: ProcessStartMode.inheritStdio,
    );
  }

  Future<int> runWithExitCode(
    String executable,
    List<String> arguments,
  ) async =>
      (await startProcess(executable, arguments)).exitCode;

  Future<String> runAsString(
    String executable,
    List<String> arguments, {
    String? errorMessage,
  }) async {
    // late final cmd = '$executable ${arguments.join(' ')}';

    final started = Process.start(
      executable,
      arguments,
      workingDirectory: this == Directory.current ? null : path,
      mode: ProcessStartMode.normal,
    );
    final process = await started;

    final result = process.stdout.transform(utf8.decoder).join();

    final stderrStream = process.stderr.listen(
      (event) {
        stderr.add(event);
      },
    );

    Future.wait([
      result,
      stderrStream.asFuture(),
    ]);

    // !!! exit code can be non-zero with still a valid output

    // await started.join(
    //   errorMessage: errorMessage ??
    //       "Error running command: $executable ${arguments.join(' ')}",
    // );

    await process.exitCode;

    return await result;
  }
}

extension FutureProcessX on Future<Process> {
  Future join({required String errorMessage}) async {
    final process = await this;
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw ('$errorMessage (exit status $exitCode)');
    }
  }
}
