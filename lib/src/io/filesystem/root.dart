part of '../filesystem.dart';

@Has()
typedef CreateRootListingWatch = AsyncCallDsp<DirectoryListingWatch>;

@Compose()
abstract class FileSystemRootActions
    implements HasCreateRootListingWatch, HasJoinAbsolutePath {}

FileSystemRootActions windowsFileSystemRootActions() {
  return ComposedFileSystemRootActions(
    createRootListingWatch: (disposers) => windowsDrives(disposers: disposers),
    joinAbsolutePath: (absoluteFilePath) =>
        path.joinAll(absoluteFilePath.filePath),
  );
}

FileSystemRootActions unixFileSystemRootActions() {
  String joinAbsolutePath(absoluteFilePath) => path.joinAll(
        [
          path.separator,
          ...absoluteFilePath.filePath,
        ],
      );
  return ComposedFileSystemRootActions(
    createRootListingWatch: (disposers) {
      return watchPathDirectory(
        absoluteFilePath: AbsoluteFilePath.root,
        fileSystemPathWatch: fileSystemRootPathWatch,
        joinAbsolutePath: joinAbsolutePath,
        disposers: disposers,
      );
    },
    joinAbsolutePath: joinAbsolutePath,
  );
}

final fileSystemRootActions = Platform.isWindows
    ? windowsFileSystemRootActions()
    : unixFileSystemRootActions();

Future<WatchRead<DirectoryListing>> windowsDrives({
  required DspReg disposers,
  int pauseDurationSeconds = 3,
}) async {
  const endMarker = r"#end";

  final drivesVar = watchVar(
    DirectoryListing.empty,
  );

  final completer = Completer();

  final complete = once(completer.complete);

  final script = """
  While (\$true) {
    Get-PSDrive -PSProvider FileSystem | Select -ExpandProperty "Root"
    Write-Output "$endMarker"
    Start-Sleep -Seconds 3
  }
  """;
  final process = await Process.start(
    "powershell",
    [
      '-Command',
      script,
    ],
  );

  final listening = process.stdout
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .bufferTest((line) => line == endMarker)
      .listen((lines) {
    final copy = lines
        .sublist(0, lines.length - 1)
        .map((line) => line.substring(0, line.length - 1))
        .map(
          (e) => DirectoryEntry(
            name: e,
            type: DirectoryEntryType.directory,
          ),
        )
        .toList();
    copy.sort(directoryEntryCompare);
    drivesVar.value = DirectoryListing(
      entries: copy.toIList(),
    );
    complete();
  });

  disposers.add(() async {
    await listening.cancel();
    process.kill();
    complete(); // not sure about this
  });

  await completer.future;

  return drivesVar;
}
