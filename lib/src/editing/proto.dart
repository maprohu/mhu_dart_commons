part of '../editing.dart';

M rebuildProtoMessage<M extends Msg>(
  M msg,
  void Function(M message) updates,
) {
  assert(M != Msg);
  return msg.rebuild(updates);
}
