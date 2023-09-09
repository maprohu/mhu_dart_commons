// part of '../filesystem.dart';
//
// typedef FileSystemAsyncTreeNodeList
//     = AsyncTreeNodeList<DirectoryNode, FileSystemLeafNode>;
//
// typedef FileSystemAsyncTreeNode
//     = AsyncTreeNode<DirectoryNode, FileSystemLeafNode>;
//
// typedef FileSystemAsyncTreeBranch
//     = AsyncTreeBranch<DirectoryNode, FileSystemLeafNode>;
//
// typedef FileSystemAsyncTreeLeaf
//     = AsyncTreeLeaf<DirectoryNode, FileSystemLeafNode>;
//
// typedef FileSystemWatchAsyncTreeChildren
//     = WatchAsyncTreeChildren<DirectoryNode, FileSystemLeafNode>;
//
// Future<ReadWatchValue<FileSystemAsyncTreeNodeList>> watchFileSystemRoot(
//   DspReg disposers,
// ) async {
//   final listingNode = await fileSystemRoots();
//
//   switch (listingNode) {
//     case SingleFileSystemRoot():
//       return await listingNode.rootDirectory
//           .directoryNode()
//           .directoryAsyncTreeBranch()
//           .watchAsyncTreeChildren(disposers)
//           .value;
//     case FileSystemRootDrives():
//       final watchDrives = listingNode.watchDiskDriveList;
//       return watching(() {
//         return watchDrives()
//             .map((drive) => drive.directoryNode().directoryAsyncTreeBranch())
//             .toIList();
//       });
//   }
// }
//
// FileSystemAsyncTreeBranch directoryAsyncTreeBranch({
//   @ext required DirectoryNode directoryNode,
// }) {
//   return ComposedAsyncTreeBranch(
//     watchAsyncTreeChildren: (disposers) {
//       return cancelableOperation((canceled) async {
//         final nodes = await directoryNode.listDirectoryNodes();
//         if (canceled()) {
//           return null;
//         }
//
//         final result = watchVar(nodes.fileSystemAsyncTreeNodeList());
//
//         final executorDisposers = DspImpl();
//         final executor = LatestExecutor<void>(
//           process: (_) async {
//             final nodes = await directoryNode.listDirectoryNodes();
//             result.value = nodes.fileSystemAsyncTreeNodeList();
//           },
//           disposers: executorDisposers,
//         );
//
//         final listening =
//             directoryNode.directory.watch().listen(executor.submit);
//
//         disposers.add(() async {
//           await listening.cancel();
//           await executorDisposers.dispose();
//         });
//
//         return result;
//       });
//     },
//     treeBranchData: directoryNode,
//   );
// }
//
// FileSystemAsyncTreeNodeList fileSystemAsyncTreeNodeList({
//   @ext required List<FileSystemEntityNode> fileSystemEntityNodes,
// }) {
//   return fileSystemEntityNodes.map<FileSystemAsyncTreeNode>((node) {
//     switch (node) {
//       case DirectoryNode():
//         return node.directoryAsyncTreeBranch();
//       case FileSystemLeafNode():
//         return ComposedAsyncTreeLeaf(
//           treeLeafData: node,
//         );
//     }
//   }).toIList();
// }
