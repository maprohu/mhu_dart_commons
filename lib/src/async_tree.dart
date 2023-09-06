import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';

import 'async_tree.dart' as $lib;

part 'async_tree.g.has.dart';

part 'async_tree.g.dart';

@Has()
typedef TreeLeafData<L> = L;

@Has()
typedef TreeBranchData<B> = B;

@Has()
typedef AsyncTreeChildren<B, L> = ReadWatchFuture<IList<AsyncTreeNode<B, L>>>;

@Has()
typedef AsyncTreeParent<B, L> = ReadWatchFuture<AsyncTreeNode<B, L>>
    Function()?;

@Has()
sealed class AsyncTreeNode<B, L> implements HasAsyncTreeParent<B, L> {}

@Compose()
abstract class AsyncTreeBranch<B, L>
    implements
        AsyncTreeNode<B, L>,
        HasCallAsyncTreeChildren<B, L>,
        HasTreeBranchData<B> {}

@Compose()
abstract class AsyncTreeLeaf<B, L>
    implements AsyncTreeNode<B, L>, HasTreeLeafData<L> {}
