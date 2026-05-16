abstract class TopicsEvent {}
class LoadTopics extends TopicsEvent {}
class CreateTopic extends TopicsEvent {
  final String title;
  CreateTopic(this.title);
}