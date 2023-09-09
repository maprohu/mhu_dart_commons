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
typedef AsyncTreeNodeList<B, L> = IList<AsyncTreeNode<B, L>>;

@Has()
typedef AsyncTreeParent<B, L> = Call<AsyncTreeBranch<B, L>>?;

@Has()
sealed class AsyncTreeNode<B, L> implements HasAsyncTreeParent<B, L> {}

@Has()
typedef WatchAsyncTreeChildren<B, L>
    = CancelableCallDsp<ReadWatchValue<AsyncTreeNodeList<B, L>>>;

@Compose()
@Has()
abstract class AsyncTreeBranch<B, L>
    implements
        AsyncTreeNode<B, L>,
        HasWatchAsyncTreeChildren<B, L>,
        HasTreeBranchData<B> {}

@Compose()
abstract class AsyncTreeLeaf<B, L>
    implements AsyncTreeNode<B, L>, HasTreeLeafData<L> {}
