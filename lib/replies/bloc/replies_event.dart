abstract class RepliesEvent {}
class LoadReplies extends RepliesEvent {
  final String topicId;
  LoadReplies(this.topicId);
}
class AddReply extends RepliesEvent {
  final String topicId, content;
  AddReply(this.topicId, this.content);
}