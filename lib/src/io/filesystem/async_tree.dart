part of '../filesystem.dart';

@Has()
typedef IODirectory = Directory;

@Has()
typedef FileSystemRoots = IList<Directory>;

sealed class ListingNode {}

@Compose()
abstract class DirectoryNode implements ListingNode, HasIODirectory {}

@Compose()
abstract class RootsNode implements ListingNode, HasFileSystemRoots {}

class FileNode {}

// Future<AsyncTreeNode<ListingNode, FileNode>> fileSystemAsyncTreeNode() async {
//   final listingNode = await fileSystemRoots();
//
//   return ComposedAsyncTreeBranch(
//     callAsyncTreeChildren: callAsyncTreeChildren,
//     treeBranchData: treeBranchData,
//   );
// }
