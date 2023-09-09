part of '../filesystem.dart';

FileSystemPathWatchPool createFileSystemPathWatchPool({
  required Call<DirectoryListingWatchPool> directoryListingWatchPool,
  required HasJoinAbsolutePath fileSystemRootActions,
}) {
  return RefCountPool((path, disposers) async {
    if (path.absolutePathIsRoot()) {
      return fileSystemRootPathWatch;
    } else {
      final basename = path.filePath.last;
      final directoryPath = path.joinAbsolutePathString(
        fileSystemRootActions: fileSystemRootActions,
      );
      final parent = await directoryListingWatchPool().acquire(
        path.absolutePathParent(),
        disposers,
      );

      final exists = disposers.watching(() {
        final listing = parent.watchValue();

        if (listing == null) {
          return false;
        }

        final foundIndex = binarySearch<DirectoryEntry>(
          listing.entries.unlockView,
          DirectoryEntry(
            name: basename,
            type: DirectoryEntryType.other,
          ),
          compare: directoryEntryCompare,
        );

        return foundIndex >= 0;
      });

      final result = watchVar(DirectoryEntryType.other);

      Future<void> update(bool exists) async {
        if (!exists) {
          result.value = DirectoryEntryType.other;
        } else {
          try {
            final type = await FileSystemEntity.type(directoryPath);
            switch (type) {
              case FileSystemEntityType.directory:
                result.value = DirectoryEntryType.directory;
              case FileSystemEntityType.file:
                result.value = DirectoryEntryType.file;
              default:
                result.value = DirectoryEntryType.other;
            }
          } catch (e) {
            logger.w(e, error: e);
            result.value = DirectoryEntryType.other;
          }
        }
      }

      await update(exists.readValue());

      final disposeExecutor = DspImpl();
      final executor = LatestExecutor<bool>(
        process: update,
        disposers: disposeExecutor,
      );

      final listening =
          exists.distinctValues().streamTail().listen(executor.submit);

      disposers.add(() async {
        await listening.cancel();
        await disposeExecutor.dispose();
      });

      return result;
    }
  });
}

final FileSystemPathWatchPool fileSystemPathWatchPool =
    createFileSystemPathWatchPool(
  directoryListingWatchPool: () => directoryListingWatchPool,
  fileSystemRootActions: fileSystemRootActions,
);

DirectoryListingWatchPool createDirectoryListingWatchPool({
  required FileSystemPathWatchPool fileSystemPathWatchPool,
  required FileSystemRootActions fileSystemRootActions,
}) {
  return RefCountPool((path, disposers) async {
    if (path.absolutePathIsRoot()) {
      return fileSystemRootActions.createRootListingWatch(disposers);
    } else {
      final pathWatch = await fileSystemPathWatchPool.acquire(path, disposers);

      return await watchPathDirectory(
        absoluteFilePath: path,
        fileSystemPathWatch: pathWatch,
        joinAbsolutePath: fileSystemRootActions.joinAbsolutePath,
        disposers: disposers,
      );
    }
  });
}

final DirectoryListingWatchPool directoryListingWatchPool =
    createDirectoryListingWatchPool(
  fileSystemPathWatchPool: fileSystemPathWatchPool,
  fileSystemRootActions: fileSystemRootActions,
);

Future<DirectoryListingWatch> watchPathDirectory({
  required AbsoluteFilePath absoluteFilePath,
  required FileSystemPathWatch fileSystemPathWatch,
  required JoinAbsolutePath joinAbsolutePath,
  required DspReg disposers,
}) async {
  final pathString = joinAbsolutePath(absoluteFilePath);
  final directory = Directory(pathString);
  final result = watchVar<DirectoryListing?>(null);

  Future<void> catching(FutureOr<void> Function() call) async {
    try {
      await call();
    } catch (e) {
      logger.w(e, error: e);
      result.value = null;
    }
  }

  Future<void> loadListing() async {
    await catching(() async {
      final listing = await directoryListing(
        directory: directory,
      );
      // logger.t([directory, listing]);
      result.value = listing;
    });
  }

  var latestDisposer = DspImpl();
  Future<void> update(DirectoryEntryType state) async {
    final tmpDisposer = latestDisposer;
    latestDisposer = DspImpl();
    await tmpDisposer.dispose();

    switch (state) {
      case DirectoryEntryType.directory:
        await loadListing();

        const events = FileSystemEvent.create |
            FileSystemEvent.delete |
            FileSystemEvent.move;

        final loadDisposers = DspImpl();
        final loadExecutor = LatestExecutor(
          process: (_) => loadListing(),
          disposers: loadDisposers,
        );
        final watching =
            directory.watch(events: events).listen(loadExecutor.submit);
        latestDisposer.add(() async {
          await watching.cancel();
          await loadDisposers.dispose();
        });
      default:
        result.value = null;
    }
  }

  await update(
    fileSystemPathWatch.readValue(),
  );
  final disposeExecutor = DspImpl();
  final executor = LatestExecutor<DirectoryEntryType>(
    process: update,
    disposers: disposeExecutor,
  );
  final listening =
      fileSystemPathWatch.distinctValues().streamTail().listen(executor.submit);

  disposers.add(() async {
    await listening.cancel();
    await disposeExecutor.dispose();
    await latestDisposer.dispose();
  });

  return result;
}
